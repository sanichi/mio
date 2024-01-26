module ConstellationHelper
  def constellation_search_order_menu(selected)
    opts = %w/name iau created/.map { |o| [t("constellation.order.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
