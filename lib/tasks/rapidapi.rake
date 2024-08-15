RAPID_COMP = 1

def rapid_report(str, error=false)
  str = JSON.generate(str, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '}) unless str.is_a?(String)
  msg = "%s%s%s" % [@print ? "" : "RAPID ", error ? "ERROR " : "", str]
  if @print
    puts msg
  else
    Rails.logger.info msg
  end
end

def rapid_response(path)
  # request the data and do some basic checks on the response
  host = Rails.application.credentials.rapidapi[:host]
  url = URI("https://#{host}/#{path}.json?comp=#{RAPID_COMP}")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(url)
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

  # return whatever we got (potentially nil)
  data
end

namespace :rapid do
  # meant to be run by hand at the beginning of the season
  # it will make sure the right teams are in the premier league
  # no output means everything is already OK
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

  desc "review all premier fixtures and results"
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
      raise "bad response" unless data
      raise "data is not a hash" unless data.is_a?(Hash)
      fixtures = data["fixtures-results"]
      raise "fixtures is not a hash" unless fixtures.is_a?(Hash)
      matches = fixtures["matches"]
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

        # if the match is in the future, we can't know the score
        if today < date
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
end
