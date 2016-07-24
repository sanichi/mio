module TaxHelper
  def tax_year_menu(number)
    n = Tax.current_year_number + 1
    opt = (0..n).map{ |y| [Tax.tax_year(y), y]}
    options_for_select(opt, number)
  end
end
