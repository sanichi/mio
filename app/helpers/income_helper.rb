module IncomeHelper
  def income_category_menu(selected)
    cats = Income::CATEGORIES.map { |cat| [t("income.category.#{cat}"), cat] }
    cats.unshift [t("select"), ""]
    options_for_select(cats, selected)
  end

  def income_period_menu(selected)
    pds = Income::PERIODS.map { |pd| [t("income.period.#{pd}"), pd] }
    pds.unshift [t("select"), ""]
    options_for_select(pds, selected)
  end
end
