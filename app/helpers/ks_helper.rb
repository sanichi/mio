module KsHelper
  def ks_app_menu(selected)
    opts = Ks::Boot::APPS.map { |a| [a, a] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def ks_boot_order_menu(selected)
    opts = %w/default happened/.map { |o| [t("ks.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def ks_journal_order_menu(selected)
    opts = %w/default created warnings problems/.map { |o| [t("ks.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def ks_server_menu(selected)
    opts = Ks::SERVERS.map { |s| [s, s] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end
end
