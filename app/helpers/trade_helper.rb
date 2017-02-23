module TradeHelper
  def trade_order_search_menu(order)
    opts =
    [
      ["#{t('date')} #{t('symbol.up')}", "date_desc"],
      ["#{t('date')} #{t('symbol.down')}", "date_asc"],
      ["#{t('trade.profit')} #{t('symbol.up')}", "profit_desc"],
      ["#{t('trade.profit')} #{t('symbol.down')}", "profit_asc"],
      ["#{t('trade.stock')} #{t('symbol.down')}", "stock"],
    ]
    options_for_select(opts, order)
  end
end
