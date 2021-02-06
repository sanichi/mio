namespace :match do
  def report(str, error=false)
    msg = "%s%s%s" % [@print ? "" : "MATCH ", error ? "ERROR " : "", str]
    if @print
      puts msg
    else
      Rails.logger.info msg
    end
  end

  def find_team(name)
    @cache ||= Hash.new
    return @cache[name] if @cache[name]
    team = Team.find_by(name: name)
    if team
      @cache[name] = team
    else
      report "can't find team '#{name}'", true
    end
    team
  end

  def scrape(team, scope, season)
    report "doing #{team.short}"
    results = scope == "monthly" ? team.monthResults : team.seasonResults
    unless results.is_a?(Array)
      report result, true
      return
    end
    results.each do |r|
      if r.is_a?(Hash)
        home_team = find_team(r[:home_team]) || next
        away_team = find_team(r[:away_team]) || next
        match = Match.find_by(home_team_id: home_team.id, away_team_id: away_team.id, season: season)
        if match
          updates = 0
          if r[:date].present? && match.date != r[:date]
            match.update_column(:date, r[:date])
            updates+= 1
          end
          if r[:home_score].present? && match.home_score != r[:home_score]
            match.update_column(:home_score, r[:home_score])
            updates+= 1
          end
          if r[:away_score].present? && match.away_score != r[:away_score]
            match.update_column(:away_score, r[:away_score])
            updates+= 1
          end
          report "#{updates == 0 ? 'matched' : 'updated'} #{match.summary}"
        else
          begin
            match = Match.create!(home_team_id: home_team.id, away_team_id: away_team.id, season: season, date: r[:date], home_score: r[:home_score], away_score: r[:away_score])
            report "created #{match.summary}"
          rescue => e
            report "#{r} #{e.message}", true
          end
        end
      else
        report "result: #{r}", true
      end
    end
  end

  desc "scrape monthly or seasonal data for all the premier league teams"
  task :all, [:scope] => :environment do |task, args|
    scope = args[:scope] == "s" ? "seasonal" : "monthly"
    report "starting #{scope} scrape"
    Team.where(division: 1).all.each { |team| scrape(team, scope, Match.current_season) }
  end

  desc "scrape monthly data for one premier league team"
  task :one, [:name] => :environment do |task, args|
    name = args[:name].present? ? args[:name] : "Manchester City"
    team = Team.find_by(name: name) || Team.find_by(short: name)
    @print = true
    if team
      report "scraping #{team.name}"
      scrape(team, "monthly", Match.current_season)
    else
      report "could't find '#{name}'", true
    end
  end
end
