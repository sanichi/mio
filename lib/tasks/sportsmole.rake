# Refs:
#   https://www.zenrows.com/blog/web-scraping-ruby
#   https://www.sportsmole.co.uk/football/premier-league/2018-19/results.html

namespace :mole do
  # Meant to be run by hand in development or production.
  # Scrapes historical data from sportsmole and then either compares
  # it with what we already have or adds it as new data to the database.
  # Examples:
  #   ❯ bin/rails mole:data\[2020\]
  #   $ RAILS_ENV=production bin/rails mole:data\[2019\]
  desc "get or check historical premier league data"
  task :data, [:season] => :environment do |task, args|
    begin
      # get the season
      raise "missing season" if args[:season].blank?
      season = args[:season].to_i
      raise "invalid season (#{season})" if season < Match::MIN_SEASON || season >= Match.current_season

      # do we have any games from that season?
      count = Match.where(season: season).count
      case count
      when 0
        check = false
      when 380
        check = true
      else
        raise "something is wrong: found #{count} games in season #{season}"
      end

      # get hashes that will allow us to turn their names into our IDs
      n2id = {}
      Team.pluck(:name, :short, :id).each do |name, short, id|
        n2id[name] = id
        n2id[short] = id
      end
      n2id["Man Utd"] = n2id["Man United"]

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
      matches = 0
      home_matches = Hash.new(0)
      away_matches = Hash.new(0)

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
        matches += 1
        home_matches[home] += 1
        away_matches[away] += 1
      end

      # check stats
      raise "wrong number of matches (#{matches})" unless matches == 380
      raise "wrong number of home teams (#{home_matches.size})" unless home_matches.size == 20
      raise "wrong number of away teams (#{away_matches.size})" unless away_matches.size == 20
      home_matches.each_pair do |name, count|
        raise "wrong number of home matches (#{count}) for #{name}" unless count == 19
      end
      away_matches.each_pair do |name, count|
        raise "wrong number of away matches (#{count}) for #{name}" unless count == 19
      end

      # all seems OK
      puts "OK"
    rescue => e
      puts e.message
    end
  end
end
