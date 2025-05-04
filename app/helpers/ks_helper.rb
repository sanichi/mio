module KsHelper
  def ks_journal_order_menu(selected)
    opts = %w/default created warnings problems/.map { |o| [t("ks.journal.order.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
