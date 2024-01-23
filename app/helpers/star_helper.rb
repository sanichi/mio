module StarHelper
  def star_search_order_menu(selected)
    opts = %w/name distance created/.map { |o| [t("star.order.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
