module MisaHelper
  def misa_search_order_menu(selected)
    opts = %w/updated created published/.map { |o| [t("misa.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def misa_series_menu(selected)
    opts = Misa.pluck(:series).uniq.compact.sort.map { |s| [s, s] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end
end
