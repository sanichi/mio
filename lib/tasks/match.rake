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
      report results, true
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
          match.touch if updates > 0
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

  # Meant for nightly cron. For example:
  # 0 22 * * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails match:all >> log/cron.log 2>&1
  desc "scrape monthly or seasonal data for all the premier league teams"
  task :all, [:scope] => :environment do |task, args|
    scope = args[:scope] == "s" ? "seasonal" : "monthly"
    report "starting #{scope} scrape"
    Team.where(division: 1).all.each { |team| scrape(team, scope, Match.current_season) }
  end

  # Meant for quick update initiated from development laptop. For examle:
  # bin/cap production match:one # default is Man City
  # bin/cap production match:one\[Liverpool\]
  desc "scrape monthly data for one premier league team"
  task :one, [:name] => :environment do |task, args|
    name = args[:name].present? ? args[:name] : "Manchester City"
    team = Team.find_by(name: name) || Team.find_by(short: name) || Team.find_by(slug: name)
    @print = true
    if team
      scrape(team, "monthly", Match.current_season)
    else
      report "could't find '#{name}'", true
    end
  end

  # Meant to check for changes in layout of page. For examle:
  # bin/cap production match:check # default is Man City
  # bin/cap production match:check\[Man Utd\]
  desc "check page layout for one premier league team"
  task :check, [:name] => :environment do |task, args|
    name = args[:name].present? ? args[:name] : "Manchester City"
    team = Team.find_by(name: name) || Team.find_by(short: name) || Team.find_by(slug: name)
    if team
      puts "found #{team.name}"
      team.checkResults
    else
      puts "could't find '#{name}'"
    end
  end
end
