module MatchHelper
  def match_season(season) = "%d/%d" % [season % 100, season % 100 + 1]
  def full_match_season(season) = "%d/%d" % [season, season % 100 + 1]

  def match_season_menu
    opts = Match.pluck(:season).uniq.sort.map { |s| [match_season(s), s] }
    opts.unshift [t("any"), ""]
    options_for_select(opts)
  end

  def match_played_menu
    opts = [[t("any"), 0], [t("match.played"), 1], [t("match.unplayed"), 2]]
    options_for_select(opts)
  end
end
