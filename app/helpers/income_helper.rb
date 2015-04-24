module IncomeHelper
  def income_category_menu(income)
    cats = Income::CATEGORIES.map { |cat| [t("income.category.#{cat}"), cat] }
    cats.unshift [t("select"), ""] if income.new_record?
    options_for_select(cats, income.category)
  end

  def income_period_menu(income)
    pds = Income::PERIODS.map { |pd| [t("income.period.#{pd}"), pd] }
    pds.unshift [t("select"), ""] if income.new_record?
    options_for_select(pds, income.period)
  end
end
