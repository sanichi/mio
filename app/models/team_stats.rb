class TeamStats
  attr_reader :name, :names, :ids, :seasons, :pts, :gds, :home, :away

  def initialize(team)
    @name = team.name
    @seasons = []
    count = Hash.new(0)
    @pts = Hash.new(0)
    @gds = Hash.new(0)

    @home = Hash.new { |h,k| h[k] = Hash.new }
    Match.where(home_team_id: team.id).each do |match|
      if (og = match.home_score).present? && (tg = match.away_score).present?
        id = match.away_team_id
        pt = og == tg ? 1 : (og > tg ? 3 : 0)

        count[id] += 1
        @pts[id] += pt
        @gds[id] += og - tg
        @home[id][match.season] = [og, tg, pt]
        @seasons.push match.season unless @seasons.include?(match.season)
      end
    end

    @away = Hash.new { |h,k| h[k] = Hash.new }
    Match.where(away_team_id: team.id).each do |match|
      if (tg = match.home_score).present? && (og = match.away_score).present?
        id = match.home_team_id
        pt = og == tg ? 1 : (og > tg ? 3 : 0)

        count[id] += 1
        @pts[id] += pt
        @gds[id] += og - tg
        @away[id][match.season] = [og, tg, pt]
        @seasons.push match.season unless @seasons.include?(match.season)
      end
    end
    @seasons.sort!

    @ids = []
    @names = {}
    Team.pluck(:id, :short).each do |id,short|
      if count[id] > 0
        @ids.push id
        @names[id] = short
      end
    end
    @ids.sort! { |a,b| [@pts[b], @gds[b]] <=> [@pts[a], @gds[a]] }
  end
end
