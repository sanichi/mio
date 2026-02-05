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
    opts = Pp::Station.by_display_name.map { |s| [s.display_name, s.id] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end
end
