module ExpenseHelper
  def expense_category_menu(selected)
    cats = Expense::CATEGORIES.map { |cat| [t("expense.category.#{cat}"), cat] }
    cats.unshift [t("select"), ""]
    options_for_select(cats, selected)
  end

  def expense_period_menu(selected)
    pds = Expense::PERIODS.map { |pd| [t("expense.period.#{pd}"), pd] }
    pds.unshift [t("select"), ""]
    options_for_select(pds, selected)
  end
end
