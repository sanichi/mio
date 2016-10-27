module TradesHelper
  def trade_order_search_menu(order)
    opts =
    [
      ["#{t('trade.profit')} #{t('symbol.up')}", "profit_asc"],
      ["#{t('trade.profit')} #{t('symbol.down')}", "profit_desc"],
      ["#{t('trade.stock')} #{t('symbol.down')}", "stock"],
    ]
    options_for_select(opts, order)
  end
end
