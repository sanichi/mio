module PpHelper
  def pp_query_type_menu(selected)
    opts = Pp::SyncLog::QUERY_TYPES.map { |qt| [t("pp.sync_log.query_types.#{qt}"), qt] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end

  def pp_station_order_menu(selected)
    opts = [
      [t("pp.price.price"), "price"],
      [t("pp.station.name"), "name"]
    ]
    options_for_select(opts, selected)
  end

  def pp_station_filter_menu(selected)
    opts = Pp::Station.where(id: Pp::Price.select(:station_id)).by_display_name.map { |s| [s.display_name, s.id] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end

  def pp_price_order_menu(selected)
    opts = []
    opts.push ["#{t('pp.price.price_last_updated')} #{t('symbol.down')}", "update_down"]
    opts.push ["#{t('pp.price.price_last_updated')} #{t('symbol.up')}", "update_up"]
    opts.push ["#{t('pp.price.price')} #{t('symbol.down')}", "price_down"]
    opts.push ["#{t('pp.price.price')} #{t('symbol.up')}", "price_up"]
    opts.push [t("pp.station.station"), "station"]
    options_for_select(opts, selected)
  end
end
