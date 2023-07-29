module TransactionHelper
  def transaction_account_menu(selected)
    opts = Transaction::ACCOUNTS.values.uniq.map{|a| [t("transaction.accounts.#{a}"), a]}
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def transaction_category_menu(selected)
    opts = Transaction.pluck(:category).uniq.sort.map{|c| [c, c]}
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def transaction_order_menu(selected)
    opts = t("transaction.orders").map{|k,v| [v, k.to_s]}
    options_for_select(opts, selected)
  end

  def transaction_classifier_menu(selected)
    opts = Classifier.pluck(:name, :id)
    opts.unshift [t("transaction.approved"), -2]
    opts.unshift [t("transaction.unclassified"), -1]
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def transaction_date(date) = date.strftime("%y\u2011%m\u2011%d")
end
