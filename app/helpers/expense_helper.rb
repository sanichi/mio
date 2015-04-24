module ExpenseHelper
  def expense_category_menu(expense)
    cats = Expense::CATEGORIES.map { |cat| [t("expense.category.#{cat}"), cat] }
    cats.unshift [t("select"), ""] if expense.new_record?
    options_for_select(cats, expense.category)
  end

  def expense_period_menu(expense)
    pds = Expense::PERIODS.map { |pd| [t("expense.period.#{pd}"), pd] }
    pds.unshift [t("select"), ""] if expense.new_record?
    options_for_select(pds, expense.period)
  end
end
