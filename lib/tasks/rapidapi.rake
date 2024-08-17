# Refs:
#   https://www.footballwebpages.co.uk/api
#   https://rapidapi.com/football-web-pages1-football-web-pages-default/api/football-web-pages1

# competition id for the premier league
RAPID_COMP = 1

# print feedback to the console or in the logs
def rapid_report(str, error=false)
  str = JSON.generate(str, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '}) unless str.is_a?(String)
  msg = "%s%s%s" % [@print ? "" : "RAPID ", error ? "ERROR " : "", str]
  if @print
    puts msg
  else
    Rails.logger.info msg
  end
end

# request api data
def rapid_response(path, team: nil)
  # setup the request and execute it
  host = Rails.application.credentials.rapidapi[:host]
  url = "https://#{host}/#{path}.json?comp=#{RAPID_COMP}"
  url+= "&team=#{team}" if team.present?
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request["x-rapidapi-key"] = Rails.application.credentials.rapidapi[:key]
  request["x-rapidapi-host"] = host
  r = http.request(request)
  if r.code != "200" || r.content_type != "application/json"
    rapid_report("path: #{path}, code: #{r.code}, content type: #{r.content_type}, message: #{r.message}", true)
    return nil
  end

  # parse the response JSON
  json = r.read_body
  data = nil
  begin
    data = JSON.parse(r.read_body)
  rescue => p
    rapid_report("path: #{path}, parse error: #{p.message}, JSON...", true)
    rapid_report(json)
  end

  # return whatever we got (might be nil if problem)
  data
end

# get matches from the fixtures-results response
def rapid_matches(data)
  raise "bad response" unless data
  raise "data is not a hash" unless data.is_a?(Hash)
  fixtures = data["fixtures-results"]
  raise "fixtures is not a hash" unless fixtures.is_a?(Hash)
  matches = fixtures["matches"]
  raise "matches is not an array" unless matches.is_a?(Array)
  matches
end

namespace :rapid do
  # Meant to be run by hand at the beginning of the season.
  # It will make sure the right teams are in the premier league.
  # No output means everything is already OK.
  # Example: $ RAILS_ENV=production bin/rails rapid:teams
  desc "check premier league teams"
  task :teams => :environment do |task|
    @print = true

    # get the data
    path = "teams"
    data = rapid_response(path)

    # check and process the structure
    twenty = []
    begin
      raise "bad response" unless data
      raise "data is not a hash with a 'teams' key" unless data.is_a?(Hash) && data.has_key?("teams")
      teams = data["teams"]
      raise "data is not an array with 20 items" unless teams.is_a?(Array) && teams.size == 20

      # make sure each of these 20 teams is in the premier league
      teams.each_with_index do |t, i|
        # get the team data
        rid = t["id"];
        raise "team #{i} has invalid id" unless rid.is_a?(Integer) && rid >= 0
        name = t["full-name"];
        raise "team #{i} has invalid name" unless name && name.is_a?(String) && name.length > 5

        # match this to our database
        team = Team.find_by(name: name)
        raise "no such team as #{name}" unless team

        # update the rapid id of the team if necessary
        if team.rid.nil?
          team.update_column(:rid, rid)
          puts "set rapid id for #{name}"
        elsif team.rid != rid
          raise "#{name} already has a rapid id (#{team.rid} <=> #{rid})" unless team
        end

        # update the division if necessary
        if team.division != 1
          team.update_column(:division, 1)
          puts "promoted #{name} to premier league"
        end

        # keep a note of the 20 teams that are in the premier league
        twenty.push(name)
      end

      # find and update teams that are no longer in the premier league
      premier = Team.where(division: 1).to_a
      if premier.size > 20
        premier.each do |team|
          unless twenty.include?(team.name)
            team.update_column(:division, 2)
            puts "relegated #{team.name} from premier league"
          end
        end
      end
    rescue => e
      rapid_report("#{path}: #{e.message}", true)
      rapid_report(data) if data
    end
  end

  # Meant to normally be run from cron on a regular (e.g. every night) basis.
  # Creates or updates db matches from api data.
  # Example: 0 22 * * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails rapid:fixtures >> log/cron.log 2>&1
  # Example: $ RAILS_ENV=production bin/rails rapid:teams\[p\]
  desc "review and update all fixtures and results"
  task :fixtures, [:print] => :environment do |task, args|
    @print = args[:print] == "p"

    # get some stuff we'll need
    season = Match.current_season
    today = Date.today

    # get the data
    path = "fixtures-results"
    data = rapid_response(path)

    # check and process the structure
    begin
      matches = rapid_matches(data)

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
          date = Date.parse(m["date"].to_s)
        rescue Date::Error => e
          raise "#{pfx} does not have a valid date"
        end

        # check the competition
        competition = m["competition"]
        raise "#{pfx} competition is not a hash" unless competition.is_a?(Hash)
        raise "#{pfx} competition id is invalid" unless competition["id"] == RAPID_COMP

        # get the home team and the corresponding one from the database
        home = m["home-team"]
        raise "#{pfx} home-team is not a hash" unless home.is_a?(Hash)
        rid = home["id"]
        raise "#{pfx} does not have a valid home team id" unless rid.is_a?(Integer) && rid >= 0
        if cache[rid]
          home_team = cache[rid]
        else
          home_team = Team.find_by(rid: rid)
          raise "#{pfx} home team id (#{rid}) has no match in db" unless home_team
          cache[rid] = home_team 
        end
        raise "#{pfx} home team name mismatch (#{home_team.name} <=> #{home["name"]})" unless home_team.name == home["name"]
        home_score = home["score"]
        raise "#{pfx} does not have a valid home score" unless home_score.is_a?(Integer) && home_score >= 0

        # get the away team and the corresponding one from the database
        away = m["away-team"]
        raise "#{pfx} away-team is not a hash" unless away.is_a?(Hash)
        rid = away["id"]
        raise "#{pfx} does not have a valid away team id" unless rid.is_a?(Integer) && rid >= 0
        if cache[rid]
          away_team = cache[rid]
        else
          away_team = Team.find_by(rid: rid)
          raise "#{pfx} away team id (#{rid}) has no match in db" unless away_team
          cache[rid] = away_team 
        end
        raise "#{pfx} away team name mismatch (#{away_team.name} <=> #{away["name"]})" unless away_team.name == away["name"]
        away_score = away["score"]
        raise "#{pfx} does not have a valid away score" unless away_score.is_a?(Integer) && away_score >= 0

        # sanity check
        raise "#{pfx} home and away teams are identical" if home_team.id == away_team.id

        # get the status
        status = m["status"]
        raise "#{pfx} status is not a hash" unless status.is_a?(Hash)
        short_status = status["short"]
        raise "#{pfx} status has no short value" unless short_status.is_a?(String)

        # how do we know if the match has started?
        # keep in mind we can't use
        #   started = true if today > date 
        # in case the match is delayed and not yet rescheduled
        if today < date
          started = false
        else
          started = home_score > 0 || away_score > 0 || short_status == "FT"
        end

        # we can't yet know the score if the match has not started
        unless started
          home_score = nil
          away_score = nil
        end

        # create or update the match object
        match = Match.find_by(home_team_id: home_team.id, away_team_id: away_team.id, season: season)
        if match
          updates = 0
          if match.date != date
            rapid_report("updated #{home_team.short} - #{away_team.short} date (#{match.date.to_s} => #{date.to_s})")
            match.update_column(:date, date)
            updates += 1
          end
          if match.home_score != home_score || match.away_score != away_score
            rapid_report("updated #{home_team.short} - #{away_team.short} score (#{match.home_score || "?"}-#{match.away_score || "?"} => #{home_score || "?"}-#{away_score || "?"})")
            match.update_column(:home_score, home_score) if match.home_score != home_score
            match.update_column(:away_score, away_score) if match.away_score != away_score
            updates += 1
          end
          match.touch if updates > 0
        else
          begin
            match = Match.create!(home_team_id: home_team.id, away_team_id: away_team.id, season: season, date: date, home_score: home_score, away_score: away_score)
            rapid_report "created #{match.summary}"
          rescue => e
            raise "#{pfx} couldn't create match (#{e.message})"
          end
        end
      end
    rescue => e
      rapid_report("#{path}: #{e.message}", true)
      rapid_report(data) if data
    end
  end

  # Meant to be run by hand as a debugging aid.
  # Compares the data for a particular fixture coming from the rapidapi and currently in the db.
  # Example: $ RAILS_ENV=production bin/rails rapid:match\[Man\ City,Man\ United\]
  desc "review one particular fixture"
  task :match, [:home, :away] => :environment do |task, args|
    @print = true

    # get some stuff we'll need
    season = Match.current_season
    home = args[:home]
    away = args[:away]

    # identify the teams and get the data
    begin
      # identify the home team
      raise "please supply a home team hint (e.g. bin/rails rapid:match\\[man\\ city,man\\ uni\\]" unless home.present?
      home_teams = Team.find_top_team(home)
      case home_teams.length
      when 0
        raise "no home team match for '#{home}'"
      when 1
        home_team = home_teams.first
      else
        raise "ambiguous home team match for '#{home}': #{home_teams.map(&:name).join(' | ')}"
      end

      # identify the away team
      raise "please supply a away team hint (e.g. bin/rails rapid:match\\[arse,chel\\]" unless away.present?
      away_teams = Team.find_top_team(away)
      case away_teams.length
      when 0
        raise "no away team match for '#{away}'"
      when 1
        away_team = away_teams.first
      else
        raise "ambiguous away team match for '#{away}': #{away_teams.map(&:name).join(' | ')}"
      end

      # try to find the match
      match = Match.find_by(home_team_id: home_team.id, away_team_id: away_team.id, season: season)
      if match
        rapid_report("db data: #{match.summary}")
      else
        rapid_report("no db match found for #{home_team.short} - #{away_team.short} in #{season}")
      end

      # get the rapid api data
      raise "#{home_team.short} has no rapid id" unless home_team.rid.is_a?(Integer)
      raise "#{away_team.short} has no rapid id" unless away_team.rid.is_a?(Integer)
      data = rapid_response("fixtures-results", team: home_team.rid)

      # get and check match data
      matches = rapid_matches(data)

      # search through these matches
      found = false
      matches.each_with_index do |m, i|
        pfx = "match #{i}"
        raise "#{pfx} is not a hash" unless m.is_a?(Hash)
        mid = m["id"]
        raise "#{pfx} does not have a valid id" unless mid.is_a?(Integer) && mid >= 0
        pfx = "#{pfx} (id #{mid})"

        # check the competition
        competition = m["competition"]
        raise "#{pfx} competition is not a hash" unless competition.is_a?(Hash)
        # raise "#{pfx} competition id is invalid" unless competition["id"] == RAPID_COMP

        # there seems to be a bug in the api that allows not premier league matches
        next unless competition["id"] == RAPID_COMP

        # get the date
        begin
          date = Date.parse(m["date"].to_s)
        rescue Date::Error => e
          raise "#{pfx} does not have a valid date"
        end

        # get the home team and the corresponding one from the database
        home = m["home-team"]
        raise "#{pfx} home-team is not a hash" unless home.is_a?(Hash)
        rid = home["id"]
        raise "#{pfx} does not have a valid home team id" unless rid.is_a?(Integer) && rid >= 0
        next unless rid == home_team.rid

        # get the away team and the corresponding one from the database
        away = m["away-team"]
        raise "#{pfx} away-team is not a hash" unless away.is_a?(Hash)
        rid = away["id"]
        raise "#{pfx} does not have a valid away team id" unless rid.is_a?(Integer) && rid >= 0
        next unless rid == away_team.rid

        # we found it
        found = true
        rapid_report("api data:")
        rapid_report(m)
        break
      end

      # if we didn't find it
      rapid_report("api data: not found") unless found
    rescue => e
      rapid_report(e.message)
    end
  end
end
