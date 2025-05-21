module TeamHelper
  def team_menu
    opts = Team.by_short.pluck(:short, :id)
    opts.unshift [t("any"), ""]
    options_for_select(opts)
  end
end
