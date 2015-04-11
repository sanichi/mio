module FundHelper
  def fund_category_menu(selected)
    cats = Fund::CATEGORIES.map { |cat| [t("fund.category.#{cat}"), cat] }
    cats.unshift [t("select"), ""]
    options_for_select(cats, selected)
  end
end
