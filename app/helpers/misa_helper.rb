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
end
