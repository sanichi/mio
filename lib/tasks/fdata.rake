# Ref: https://docs.football-data.org/general/v4/index.html

# main API URL for the premier league
FD_URL = "https://api.football-data.org/v4/competitions/PL/"

class FdTeam
  def initialize(team_hash, i)
    @data = team_hash
    @i = i
    validate!
  end

  def id = @id || @data["id"]
  def name = @name || normalize_name

  private

  def short_name = @short_name || @data["shortName"]

  def normalize_name
    case short_name
    when "Tottenham" then "Spurs"
    when "Wolverhampton" then "Wolves"
    when "Nottingham" then "Forest"
    when "Brighton Hove" then "Brighton"
    else short_name
    end
  end

  def validate!
    raise "invalid team data (##{@i})" unless @data.is_a?(Hash)
    raise "invalid team id (##{@i})" unless id.is_a?(Integer) && id >= 0
    raise "invalid team short name (##{@i})" unless short_name.is_a?(String) && short_name.length > 0
  end
end

class FdMatch
  def initialize(match_hash, i)
    @data = match_hash
    @i = i
    validate!
  end

  def date = @date ||= Date.parse(@data["utcDate"].to_s)
  def home_team_id = @home_team_id ||= @data.dig("homeTeam", "id")
  def away_team_id = @away_team_id ||= @data.dig("awayTeam", "id")
  def home_score = @home_score ||= extract_score("home")
  def away_score = @away_score ||= extract_score("away")

  private

  def extract_score(side) = @data.dig("score", "fullTime", side) || @data.dig("score", "halfTime", side)

  def validate!
    raise "invalid match data (##{@i})" unless @data.is_a?(Hash)

    begin
      date
    rescue Date::Error
      raise "invalid match date (##{@i})"
    end

    raise "invalid home team id (##{@i})" unless home_team_id.is_a?(Integer) && home_team_id >= 0
    raise "invalid away team id (##{@i})" unless away_team_id.is_a?(Integer) && away_team_id >= 0
    raise "home and away teams are identical (##{@i})" if home_team_id == away_team_id

    unless home_score.nil? || (home_score.is_a?(Integer) && home_score >= 0)
      raise "invalid home score (##{@i})"
    end
    unless away_score.nil? || (away_score.is_a?(Integer) && away_score >= 0)
      raise "invalid away score (##{@i})"
    end
  end
end

# print feedback to the console or in the logs
def report(str, error=false)
  str = JSON.generate(str, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '}) unless str.is_a?(String)
  msg = "%s%s%s" % [@print ? "" : "FDATA ", error ? "ERROR " : "", str]
  if @print
    puts msg
  else
    Rails.logger.info msg
  end
end

# get a DB team using an API id
def retrieve_team(rid, cache, i)
  return cache[rid] if cache[rid]
  team = Team.find_by(rid: rid)
  raise "team id #{rid} has no match in DB (##{i})" unless team
  cache[rid] = team 
  team
end

# get the match score from both a DB Match and a FdMatch
def match_score(match) = "#{match.home_score || '?'}-#{match.away_score || '?'}"

# request API data
def api_data(path)
  # setup the request and execute it
  url = FD_URL + path
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request["X-AUTH-TOKEN"] = Rails.application.credentials.fdataapi[:key]
  r = http.request(request)
  if r.code != "200" || r.content_type != "application/json"
    report("path: #{path}, code: #{r.code}, content type: #{r.content_type}, message: #{r.message}", true)
    return nil
  end

  # parse the response JSON
  json = r.read_body
  data = nil
  begin
    data = JSON.parse(r.read_body)
  rescue => p
    report("path: #{path}, parse error: #{p.message}, JSON...", true)
    report(json)
  end

  # return whatever we got (might be nil if problem)
  data
end

namespace :fdata do
  # Meant to be run by hand at the beginning of the season.
  # It will make sure the all teams have a football-data id.
  # No output means everything is already OK.
  # Example: $ RAILS_ENV=production bin/rails fdata:teams
  desc "check premier league teams"
  task :teams => :environment do |task|
    @print = true

    # get the data
    data = api_data("teams")

    # check and process the structure
    begin
      raise "bad data (#{data.class})" unless data.is_a?(Hash)
      teams = data.dig("teams")
      raise "bad teams (#{teams.class})" unless teams.is_a?(Array)
      raise "bad number of teams (#{teams.size})" unless teams.size == 20

      # make sure each of these 20 teams is in the database with the correct API ID
      teams.each_with_index do |team_data, i|
        # extract and validate the data for this team
        fd_team = FdTeam.new(team_data, i)

        # match to a team in our database
        db_team = Team.find_by(name: fd_team.name)
        db_team = Team.find_by(short: fd_team.name) unless db_team
        raise "no such team as #{fd_team.name} (#{i})" unless db_team

        # update the API id of the db_team if necessary
        # it's called rid (short for rapid id) after a previous API name
        if db_team.rid != fd_team.id
          puts "setting API id for #{db_team.name} (#{db_team.rid} => #{fd_team.id})"
          db_team.update_column(:rid, fd_team.id)
        end
      end
    rescue => e
      report(e.message, true)
    end
  end

  # Meant to normally be run from cron on a regular (e.g. every night) basis.
  # Creates or updates db matches from api data.
  # Example: 0 22 * * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails fdata:matches >> log/cron.log 2>&1
  # Example: $ RAILS_ENV=production bin/rails fdata:matches\[p\]
  desc "review and update all matches"
  task :matches, [:print] => :environment do |task, args|
    @print = args[:print] == "p"

    # get some stuff we'll need
    season = Match.current_season

    # get the data
    data = api_data("matches")

    # check and process the structure
    begin
      raise "bad data (#{data.class})" unless data.is_a?(Hash)
      matches = data.dig("matches")
      raise "bad matches (#{matches.class})" unless matches.is_a?(Array)
      raise "bad number of matches (#{matches.size})" unless matches.size == 380

      # prepare to cache the lookup of DB teams from API ids
      cache = {}

      # sync the matches with the database
      matches.each_with_index do |match_data, i|
        # extract and validate the data for this match
        fd_match = FdMatch.new(match_data, i)

        # get the home and away DB teams
        home_team = retrieve_team(fd_match.home_team_id, cache, i)
        away_team = retrieve_team(fd_match.away_team_id, cache, i)

        # create or update the DB match object
        db_match = Match.find_by(home_team_id: home_team.id, away_team_id: away_team.id, season: season)
        if db_match
          updates = 0
          if db_match.date != fd_match.date
            report("updated #{home_team.short} - #{away_team.short} date (#{db_match.date.to_s} => #{fd_match.date.to_s})")
            db_match.update_column(:date, fd_match.date)
            updates += 1
          end
          if match_score(db_match) != match_score(fd_match)
            report("updated #{home_team.short} - #{away_team.short} score (#{match_score(db_match)} => #{match_score(fd_match)})")
            db_match.update_column(:home_score, fd_match.home_score) if db_match.home_score != fd_match.home_score
            db_match.update_column(:away_score, fd_match.away_score) if db_match.away_score != fd_match.away_score
            updates += 1
          end
          db_match.touch if updates > 0
        else
          begin
            db_match = Match.create!(home_team_id: home_team.id, away_team_id: away_team.id, season: season, date: fd_match.date, home_score: fd_match.home_score, away_score: fd_match.away_score)
            report "created #{db_match.summary}"
          rescue => e
            raise "couldn't create match (##{i}): #{e.message}"
          end
        end
      end
    rescue => e
      report(e.message, true)
    end
  end
end
