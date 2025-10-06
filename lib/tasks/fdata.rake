# Ref: https://docs.football-data.org/general/v4/index.html

# main API URL for the premier league
FDATA_URL = "https://api.football-data.org/v4/competitions/PL/"

class TeamData
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
    raise "invalid team data (#{@i})" unless @data.is_a?(Hash)
    raise "missing team id (#{@i})" unless id.is_a?(Integer) && id >= 0
    raise "invalid team short name (#{@i})" unless short_name.is_a?(String) && short_name.length > 0
  end
end

# print feedback to the console or in the logs
def fdata_report(str, error=false)
  str = JSON.generate(str, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '}) unless str.is_a?(String)
  msg = "%s%s%s" % [@print ? "" : "FDATA ", error ? "ERROR " : "", str]
  if @print
    puts msg
  else
    Rails.logger.info msg
  end
end

# request api data
def fdata_response(path)
  # setup the request and execute it
  url = FDATA_URL + path
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request["X-AUTH-TOKEN"] = Rails.application.credentials.fdataapi[:key]
  r = http.request(request)
  if r.code != "200" || r.content_type != "application/json"
    fdata_report("path: #{path}, code: #{r.code}, content type: #{r.content_type}, message: #{r.message}", true)
    return nil
  end

  # parse the response JSON
  json = r.read_body
  data = nil
  begin
    data = JSON.parse(r.read_body)
  rescue => p
    fdata_report("path: #{path}, parse error: #{p.message}, JSON...", true)
    fdata_report(json)
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
    data = fdata_response("teams")

    # check and process the structure
    begin
      raise "bad data (#{data.class})" unless data.is_a?(Hash)
      teams = data.dig("teams")
      raise "bad teams (#{teams.class})" unless teams.is_a?(Array)
      raise "bad number of teams (#{teams&.size})" unless teams.size == 20

      # make sure each of these 20 teams is in the database with the correct API ID
      teams.each_with_index do |team_data, i|
        # extract and validate the data for this team
        fd_team = TeamData.new(team_data, i)

        # match to a team in our database
        db_team = Team.find_by(name: fd_team.name)
        db_team = Team.find_by(short: fd_team.name) unless db_team
        raise "no such team as #{fd_name.name} (#{i})" unless db_team

        # update the API id of the db_team if necessary
        # it's called rid (short for rapid id) after a previous API name
        if db_team.rid != fd_team.id
          puts "setting API id for #{db_team.name} (#{db_team.rid} => #{fd_team.id})"
          db_team.update_column(:rid, fd_team.id)
        end
      end
    rescue => e
      fdata_report(e.message, true)
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
    path = "matches"
    data = fdata_response(path)

    # check and process the structure
    begin
      raise "bad response, no matches data" unless data
      raise "data is not a hash" unless data.is_a?(Hash)
      matches = data["matches"]
      raise "matches is not an array" unless matches.is_a?(Array)

      # sync these matches with the database
      cache = {}
      matches.each_with_index do |m, i|
        pfx = "match #{i}"
        raise "#{pfx} is not a hash" unless m.is_a?(Hash)
        mid = m["id"]
        raise "#{pfx} does not have a valid id" unless mid.is_a?(Integer) && mid >= 0
        pfx = "#{pfx} (id #{mid})"

        # get the date
        begin
          date = Date.parse(m["utcDate"].to_s)
        rescue Date::Error => e
          raise "#{pfx} does not have a valid date"
        end

        # get the home team and the corresponding one from the database
        home = m["homeTeam"]
        raise "#{pfx} homeTeam is not a hash" unless home.is_a?(Hash)
        rid = home["id"]
        raise "#{pfx} does not have a valid home team id" unless rid.is_a?(Integer) && rid >= 0
        if cache[rid]
          home_team = cache[rid]
        else
          home_team = Team.find_by(rid: rid)
          raise "#{pfx} home team id (#{rid}) has no match in db" unless home_team
          cache[rid] = home_team 
        end

        # get the away team and the corresponding one from the database
        away = m["awayTeam"]
        raise "#{pfx} awayTeam is not a hash" unless away.is_a?(Hash)
        rid = away["id"]
        raise "#{pfx} does not have a valid away team id" unless rid.is_a?(Integer) && rid >= 0
        if cache[rid]
          away_team = cache[rid]
        else
          away_team = Team.find_by(rid: rid)
          raise "#{pfx} away team id (#{rid}) has no match in db" unless away_team
          cache[rid] = away_team 
        end

        # sanity check
        raise "#{pfx} home and away teams are identical" if home_team.id == away_team.id

        # get the scores
        score = m["score"]
        raise "#{pfx} score is not a hash" unless score.is_a?(Hash)
        full = score["fullTime"]
        raise "#{pfx} fullTime is not a hash" unless full.is_a?(Hash)
        half = score["halfTime"]
        raise "#{pfx} halfTime is not a hash" unless half.is_a?(Hash)
        home_score = full["home"] || half["home"]
        raise "#{pfx} fullTime home score is not a non-negative integer" unless home_score.nil? || (home_score.is_a?(Integer) && home_score >= 0)
        away_score = full["away"] || half["away"]
        raise "#{pfx} fullTime away score is not a non-negative integer" unless away_score.nil? || (away_score.is_a?(Integer) && away_score >= 0)

        # create or update the match object
        match = Match.find_by(home_team_id: home_team.id, away_team_id: away_team.id, season: season)
        if match
          updates = 0
          if match.date != date
            fdata_report("updated #{home_team.short} - #{away_team.short} date (#{match.date.to_s} => #{date.to_s})")
            match.update_column(:date, date)
            updates += 1
          end
          if match.home_score != home_score || match.away_score != away_score
            fdata_report("updated #{home_team.short} - #{away_team.short} score (#{match.home_score || "?"}-#{match.away_score || "?"} => #{home_score || "?"}-#{away_score || "?"})")
            match.update_column(:home_score, home_score) if match.home_score != home_score
            match.update_column(:away_score, away_score) if match.away_score != away_score
            updates += 1
          end
          match.touch if updates > 0
        else
          begin
            match = Match.create!(home_team_id: home_team.id, away_team_id: away_team.id, season: season, date: date, home_score: home_score, away_score: away_score)
            fdata_report "created #{match.summary}"
          rescue => e
            raise "#{pfx} couldn't create match (#{e.message})"
          end
        end
      end
    rescue => e
      fdata_report("#{path}: #{e.message}", true)
    end
  end
end
