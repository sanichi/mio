module TeamHelper
  def team_division_menu(team)
    divs = (Team::MIN_DIVISION..Team::MAX_DIVISION).map { |d| [d.to_s, d] }
    options_for_select(divs, team.division)
  end
end
