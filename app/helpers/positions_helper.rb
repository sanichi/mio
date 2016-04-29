module PositionsHelper
  def position_active_menu(active)
    opts =
    [
      [t("select"), ""],
      [t("position.white"), "w"],
      [t("position.black"), "b"],
    ]
    options_for_select(opts, active)
  end

  def position_order_search_menu(order)
    opts =
    [
      [t("name"), "name"],
      [t("updated_at"), "updated"],
      [t("created_at"), "created"],
    ]
    options_for_select(opts, order)
  end
end
