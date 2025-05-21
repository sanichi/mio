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

  def ks_datetime(time)
    today = Date.today
    fmt =
      case (today - time.to_date).to_i
      when 0
        "Today"
      when 1
        "Yesterday"
      when 2,3,4,5
        "%a"
      else
        if time.year == today.year
          "%b %e"
        else
          "%Y-%M-%D"
        end
      end
    time.strftime("#{fmt} %H:%M")
  end

  def ks_journal_order_menu(selected)
    opts = %w/default created warnings problems/.map { |o| [t("ks.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def ks_mem_order_menu(selected)
    opts = %w/default measured/.map { |o| [t("ks.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def ks_server_menu(selected)
    opts = Ks::SERVERS.map { |s| [t("ks.servers.#{s}", locale: "jp"), s] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def ks_proc_order_menu(selected)
    opts = %w/default measured memory/.map { |o| [t("ks.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def ks_pcpu_order_menu(selected)
    opts = %w/default measured pcpu/.map { |o| [t("ks.order.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
