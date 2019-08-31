module WkHelper
  def wk_level_menu(selected)
    opts = (0..Wk::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def wk_radical_order_menu(selected)
    opts = [[t("wk.radical.name"), "name"], [t("wk.level"), "level"]]
    options_for_select(opts, selected)
  end
end
