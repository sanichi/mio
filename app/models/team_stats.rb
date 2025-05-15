class TeamStats
  attr_reader :name, :seasons

  def initialize(team)
    @name = team.name

    @seasons = []
    Match.where(home_team_id: team.id).each do |match|
      @seasons.push match.season unless @seasons.include?(match.season)
    end
    @seasons.sort!
  end
end
