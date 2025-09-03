module SubscriptionHelper
  def sub_format_amount(pennies)
    return "" unless pennies.is_a?(Integer)
    "£#{sprintf('%.2f', pennies / 100.0)}"
  end

  def sub_frequency_menu(selected)
    opts = Subscription.frequencies.keys.map{|k| [I18n.t("activerecord.attributes.subscription.frequency.#{k}"), k]}
    options_for_select(opts, selected)
  end

  def sub_source_search_menu(selected)
    opts = Subscription.pluck(:source).uniq.compact.sort.map { |s| [s, s] }
    opts.unshift ["#{t('any')} #{t('subscription.source')}", ""]
    options_for_select(opts, selected)
  end

  def sub_liable_search_menu(selected)
    opts = I18n.t("subscription.liability").map{|k,v| [v, k]}
    options_for_select(opts, selected)
  end

  def sub_source_list
    Subscription.pluck(:source).uniq.compact.sort
  end
end
