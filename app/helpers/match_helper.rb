module MatchHelper
  WINNER = Hash.new("")
  [2011,2013,2017,2018,2020,2021,2022,2023].each { |s| WINNER[s] = "Man City" }
  [2010,2012].each { |s| WINNER[s] = "Man Utd" }
  [2019,2024].each { |s| WINNER[s] = "Liverpool" }
  [2014,2016].each { |s| WINNER[s] = "Chelsea" }
  WINNER[2015] = "Leicester"

  def match_season(season) = "%d/%d" % [season % 100, season % 100 + 1]
  def full_match_season(season) = "%d/%d" % [season, season % 100 + 1]

  def premier_season_menu(selected)
    opts = Match.seasons.reverse.map { |s| [full_match_season(s) + " " + WINNER[s], s] }
    options_for_select(opts, selected)
  end

  def match_season_menu
    opts = Match.seasons.map { |s| [match_season(s), s] }
    opts.unshift [t("any"), ""]
    options_for_select(opts)
  end

  def match_played_menu
    opts = [[t("any"), 0], [t("match.played"), 1], [t("match.unplayed"), 2]]
    options_for_select(opts)
  end
end
