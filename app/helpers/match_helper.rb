module MatchHelper
  def match_season(season)
    "%d/%d" % [season % 1000, season % 1000 + 1]
  end

  def match_season_menu
    opts = Match.pluck(:season).uniq.sort.map { |s| [match_season(s), s] }
    opts.unshift [t("any"), ""]
    options_for_select(opts)
  end
end
