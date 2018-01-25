module OccupationHelper
  def occupation_search_order_menu(selected)
    opts = %w/reading meaning ending kanji/.map { |g| [t("vocab.#{g}"), g] }
    options_for_select(opts, selected)
  end
  def occupation_ending_menu(selected)
    opts = %w/all sha te ka other/.map { |g| [t("vocab.occupation.ending.#{g}"), g] }
    options_for_select(opts, selected)
  end
end
