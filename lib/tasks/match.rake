namespace :match do
  def log(str, error=false)
    msg = "%s%s%s" % ["MATCH", error ? " ERROR " : " ", str]
    Rails.logger.info msg
  end

  def find_team(name)
    @cache ||= Hash.new
    return @cache[name] if @cache[name]
    team = Team.find_by(name: name)
    if team
      @cache[name] = team
    else
      log "can't find team '#{name}'", true
    end
    team
  end

  desc "scrape match data for all the premier league teams"
  task :scrape, [:opt] => :environment do |task, args|
    scope = args[:opt] == "s" ? "seasonal" : "monthly"
    log "starting #{scope} scrape"
    season = Match.current_season
    Team.where(division: 1).all.each do |team|
      log "doing #{team.short}"
      results = scope == "monthly" ? team.monthResults : team.seasonResults
      unless results.is_a?(Array)
        log result, true
        next
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
            log "#{updates == 0 ? 'matched' : 'updated'} #{match.summary}"
          else
            begin
              match = Match.create!(home_team_id: home_team.id, away_team_id: away_team.id, season: season, date: r[:date], home_score: r[:home_score], away_score: r[:away_score])
              log "created #{match.summary}"
            rescue => e
              log "#{r} #{e.message}", true
            end
          end
        else
          log "result: #{r}", true
        end
      end
    end
  end
end
