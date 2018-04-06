module MisaHelper
  def misa_category_menu(selected, search: false, new_record: false)
    opts = Misa::CATEGORIES.map { |c| [t("misa.categories.#{c}"), c] }
    if search
      opts.unshift [t("any"), ""]
    elsif new_record
      opts.unshift [t("select"), ""]
    end
    options_for_select(opts, selected)
  end

  def misa_search_order_menu(selected)
    opts = %w/updated created published/.map { |o| [t("misa.order.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
