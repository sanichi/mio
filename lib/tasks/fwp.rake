# Ref: https://www.footballwebpages.co.uk/api

# main API URL for the premier league
FWP_URL = "https://api.footballwebpages.co.uk/v2/"

class FwdTeam
  def initialize(team_hash, i)
    @data = team_hash
    @i = i
    validate!
  end

  def id = @id || @data["id"]
  def name = @name || @data["full-name"]

  private

  def validate!
    raise "invalid team data (##{@i})" unless @data.is_a?(Hash)
    raise "invalid team id (##{@i})" unless id.is_a?(Integer) && id >= 0
    raise "invalid team name (##{@i})" unless name.is_a?(String) && name.length > 0
  end
end

class FwdMatch
  def initialize(match_hash, i)
    @data = match_hash
    @i = i
    validate!
  end

  def date = @date ||= Date.parse(@data["date"].to_s)
  def status = @status ||= @data.dig("status", "short")
  def home_team_id = @home_team_id ||= @data.dig("home-team", "id")
  def away_team_id = @away_team_id ||= @data.dig("away-team", "id")
  def home_score = @home_score ||= status == "FT" ? @data.dig("home-team", "score") : nil
  def away_score = @away_score ||= status == "FT" ? @data.dig("away-team", "score") : nil
  def score = "#{home_score || '?'}-#{away_score || '?'}"

  private

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
def fwp_report(str, error=false)
  str = JSON.generate(str, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '}) unless str.is_a?(String)
  msg = "%s%s%s" % [@print ? "" : "FDATA ", error ? "ERROR " : "", str]
  if @print
    puts msg
  else
    Rails.logger.info msg
  end
end

# get a DB team using an API id
def fwp_retrieve_team(id, cache, i)
  return cache[id] if cache[id]
  team = Team.find_by(fwp_id: id)
  raise "team id #{id} has no match in DB (##{i})" unless team
  cache[id] = team
  team
end

# request API data
def fwp_api_data(path)
  # setup the request and execute it
  url = FWP_URL + path
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request["FWP-API-Key"] = Rails.application.credentials.fwp[:api]
  r = http.request(request)
  if r.code != "200" || r.content_type != "application/json"
    fwp_report("path: #{path}, code: #{r.code}, content type: #{r.content_type}, message: #{r.message}", true)
    return nil
  end

  # parse the response JSON
  json = r.read_body
  data = nil
  begin
    data = JSON.parse(r.read_body)
  rescue => p
    fwp_report("path: #{path}, parse error: #{p.message}, JSON...", true)
    fwp_report(json)
  end

  # return whatever we got (might be nil if problem)
  data
end

namespace :fwp do
  # Meant to be run by hand at the beginning of the season.
  # It will make sure the all teams have a football-data id.
  # No output means everything is already OK.
  # Example: $ RAILS_ENV=production bin/rails fdata:teams
  desc "check premier league teams"
  task :teams => :environment do |task|
    @print = true

    # get the data
    data = fwp_api_data("teams.json?comp=1")

    # check and process the structure
    begin
      raise "bad data (#{data.class})" unless data.is_a?(Hash)
      teams = data.dig("teams")
      raise "bad teams (#{teams.class})" unless teams.is_a?(Array)
      raise "bad number of teams (#{teams.size})" unless teams.size == 20

      # make sure each of these 20 teams is in the database with the correct API ID
      teams.each_with_index do |team_data, i|
        # extract and validate the data for this team
        fwp_team = FwdTeam.new(team_data, i)

        # match to a team in our database
        db_team = Team.find_by(name: fwp_team.name)
        db_team = Team.find_by(short: fwp_team.name) unless db_team
        raise "no such team as #{fwp_team.name} (#{i})" unless db_team

        # update the API id of the db_team if necessary
        if db_team.fwp_id != fwp_team.id
          puts "setting API id for #{db_team.name} (#{db_team.fwp_id} => #{fwp_team.id})"
          db_team.update_column(:fwp_id, fwp_team.id)
        end
      end
    rescue => e
      fwp_report(e.message, true)
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
    data = fwp_api_data("fixtures-results.json?comp=1")

    # check and process the structure
    begin
      raise "bad data (#{data.class})" unless data.is_a?(Hash)
      matches = data.dig("fixtures-results", "matches")
      raise "bad matches (#{matches.class})" unless matches.is_a?(Array)
      raise "bad number of matches (#{matches.size})" unless matches.size == 380

      # prepare to cache the lookup of DB teams from API ids
      cache = {}

      # sync the matches with the database
      matches.each_with_index do |match_data, i|
        # extract and validate the data for this match
        fwp_match = FwdMatch.new(match_data, i)

        # get the home and away DB teams
        home_team = fwp_retrieve_team(fwp_match.home_team_id, cache, i)
        away_team = fwp_retrieve_team(fwp_match.away_team_id, cache, i)

        # create or update the DB match object
        db_match = Match.find_by(home_team_id: home_team.id, away_team_id: away_team.id, season: season)
        if db_match
          updates = 0
          if db_match.date != fwp_match.date
            fwp_report("updated #{home_team.short} - #{away_team.short} date (#{db_match.date.to_s} => #{fwp_match.date.to_s})")
            db_match.update_column(:date, fwp_match.date)
            updates += 1
          end
          if db_match.score != fwp_match.score
            fwp_report("updated #{home_team.short} - #{away_team.short} score (#{db_match.score} => #{fwp_match.score})")
            db_match.update_column(:home_score, fwp_match.home_score) if db_match.home_score != fwp_match.home_score
            db_match.update_column(:away_score, fwp_match.away_score) if db_match.away_score != fwp_match.away_score
            updates += 1
          end
          db_match.touch if updates > 0
        else
          begin
            db_match = Match.create!(home_team_id: home_team.id, away_team_id: away_team.id, season: season, date: fwp_match.date, home_score: fwp_match.home_score, away_score: fwp_match.away_score)
            report "created #{db_match.summary}"
          rescue => e
            raise "couldn't create match (##{i}): #{e.message}"
          end
        end
      end
    rescue => e
      fwp_report(e.message, true)
    end
  end
end
