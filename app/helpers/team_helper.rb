module TeamHelper
  def team_division_menu(team)
    divs = (Team::MIN_DIVISION..Team::MAX_DIVISION).map { |d| [d.to_s, d] }
    options_for_select(divs, team.division)
  end

  def team_division_search_menu
    opts = (Team::MIN_DIVISION..Team::MAX_DIVISION).map { |d| [d.to_s, d] }
    options_for_select(opts, params[:division])
  end

  def team_menu
    opts = Team.by_short.pluck(:short, :id)
    opts.unshift [t("any"), ""]
    options_for_select(opts)
  end
end
