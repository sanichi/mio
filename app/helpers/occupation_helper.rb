module OccupationHelper
  def occupation_search_order_menu(selected)
    opts = %w/reading meaning ending kanji/.map { |g| [t("vocab.#{g}"), g] }
    options_for_select(opts, selected)
  end
  def occupation_ending_menu(selected)
    opts = Occupation::ENDINGS.map { |g| [g, g] }
    opts = opts.unshift([t("all"), "all"]).push([t("other"), "other"])
    options_for_select(opts, selected)
  end
end
