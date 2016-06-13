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

  def position_opening_menu(opening_id)
    opts = Opening.by_code.map{ |o| [o.desc, o.id] }
    opts.unshift([t("none"), ""])
    options_for_select(opts, opening_id)
  end

  def position_done_search_menu(done)
    opts =
    [
      [t("any"), ""],
      [t("symbol.tick"), "true"],
      [t("symbol.cross"), "false"],
    ]
    options_for_select(opts)
  end

  def position_order_search_menu(order)
    opts =
    [
      [t("name"), "name"],
      [t("opening.opening"), "opening"],
    ]
    options_for_select(opts, order)
  end
end
