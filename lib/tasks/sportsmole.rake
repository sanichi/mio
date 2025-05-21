# Refs:
#   https://www.zenrows.com/blog/web-scraping-ruby
#   https://www.sportsmole.co.uk/football/premier-league/2018-19/results.html

# actions
MOLE_NONE = 0
MOLE_CHECK = 1
MOLE_ADD = 2

namespace :mole do
  # Meant to be run by hand in development or production.
  # Scrapes historical data from sportsmole and then either compares
  # it with what we already have or adds it as new data to the database.
  # Examples:
  #   ❯ bin/rails mole:data\[2020\]
  #   ❯ bin/rails mole:data\[2023,C\]
  #   ❯ bin/rails mole:data\[2019,A\]
  #   $ RAILS_ENV=production bin/rails mole:data\[2019,A\]
  desc "get or check historical premier league data"
  task :data, [:season, :action] => :environment do |task, args|
    begin
      # get the season
      raise "missing season" if args[:season].blank?
      season = args[:season].to_i
      raise "invalid season (#{season})" if season < Match::MIN_SEASON || season >= Match.current_season

      # get the action
      case args[:action]
      when nil
        action = MOLE_NONE
      when /\A[Cc](heck)?\z/
        action = MOLE_CHECK
      when /\A[Aa](dd)?\z/
        action = MOLE_ADD
      else
        raise "invalid action (#{args[:action]})"
      end

      # do we already have any games from that season?
      count = Match.where(season: season).count
      raise "something is wrong: found #{count} games in season #{season}" if count > 0 && count != 380
      raise "can't check if there are no games" if action == MOLE_CHECK and count == 0
      raise "can't add if there are already games" if action == MOLE_ADD and count > 0

      # get hashes that will allow us to turn their names into our IDs
      n2id = {}
      Team.pluck(:name, :short, :id).each do |name, short, id|
        n2id[name] = id
        n2id[short] = id
      end
      n2id["Man Utd"] = n2id["Man United"]
      n2id["Sheff Utd"] = n2id["Sheffield"]
      n2id["Nott'm Forest"] = n2id["Forest"]

      # request the appropriate page
      url = "https://www.sportsmole.co.uk/football/premier-league/#{season}-#{sprintf('%02d',(season + 1) % 1000)}/results.html"
      rsp = HTTParty.get(url)
      doc = Nokogiri::HTML(rsp.body, &:noblanks)

      # sample structure
      # <div class="l_s_row_even h54p l_sf_row  fBx">
      #   <div class="hTOh even">
      #     <div class="l_sf_box l_s_teams_date">
      #       <span class="bold game_state_1 www">Apr 2, 2011</span>
      #       <span class="hour www"> 3pm</span>
      #     </div>
      #     <div class="l_sfp_one">
      #       <a class="l_sfp_links" href="/football/premier-league/birmingham-city-vs-bolton-wanderers_game_12315.html">
      #         <div class="l_sfp_two">Birmingham</div>
      #         <div class="l_sfp_three">2-1</div>
      #         <div class="l_sfp_four">Bolton</div>
      #       </a>

      # prepare to record some stats
      home_matches = Hash.new(0)
      away_matches = Hash.new(0)
      results = []

      # parse out the match data
      nodes = doc.css("div.l_sf_row")
      raise "didn't find any match nodes" unless nodes.size > 0
      nodes.each do |node|
        details = ":\n#{node.to_s}" # for error messages

        # get the date
        span = node.at_css("span.game_state_1")
        raise "didn't find match date span" + details unless span.present?
        begin
          date = Date.parse(span.text)
        rescue Date::Error
          raise "couldn't parse date from match date span" + details
        end

        # get the home team
        div = node.at_css("div.l_sfp_two")
        raise "didn't find home team div" + details unless div.present?
        home = div.text
        home_id = n2id[home]
        raise "don't recognise team (#{home})" unless home_id

        # get the score
        div = node.at_css("div.l_sfp_three")
        raise "didn't find score div" + details unless div.present?
        score = div.text
        raise "unparsable score (#{score})" + details unless score.match(/\A(\d+)-(\d+)\z/)
        home_score = $1.to_i
        away_score = $2.to_i

        # get the away team
        div = node.at_css("div.l_sfp_four")
        raise "didn't find away team div" + details unless div.present?
        away = div.text
        away_id = n2id[away]
        raise "don't recognise team (#{away})" unless away_id

        # update stats
        results.push [date, home_id, away_id, home_score, away_score]
        home_matches[home] += 1
        away_matches[away] += 1
      end

      # check stats
      raise "wrong number of results (#{results.size})" unless results.size == 380
      raise "wrong number of home teams (#{home_matches.size})" unless home_matches.size == 20
      raise "wrong number of away teams (#{away_matches.size})" unless away_matches.size == 20
      home_matches.each_pair do |name, count|
        raise "wrong number of home matches (#{count}) for #{name}" unless count == 19
      end
      away_matches.each_pair do |name, count|
        raise "wrong number of away matches (#{count}) for #{name}" unless count == 19
      end

      # all seems OK
      puts "scraped data looks good"

      # perform the action
      case action
      when MOLE_CHECK
        results.sort! { |a,b| [a[0], a[1], a[2]] <=> [b[0], b[1], b[2]] }
        matches = Match.where(season: season).order(:date, :home_team_id, :away_team_id).pluck(:date, :home_team_id, :away_team_id, :home_score, :away_score)
        results.each_with_index do |r, i|
          m = matches[i]
          raise "pair #{i} differ: #{r} <=> #{m}" unless r == m
        end
        puts "season #{season} check OK"
      when MOLE_ADD
        results.sort! { |a,b| a[0] <=> b[0] }
        results.each do |d, hid, aid, hs, as|
          Match.create!(date: d, home_team_id: hid, away_team_id: aid, home_score: hs, away_score: as, season: season)
        end
        puts "season #{season} add OK"
      end
    rescue => e
      puts e.message
    end
  end
end
