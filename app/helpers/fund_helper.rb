module FundHelper
  def fund_category_menu(selected)
    cats = Fund::CATEGORIES.map { |cat| [t("fund.category.#{cat}"), cat] }
    cats.unshift [t("select"), ""]
    options_for_select(cats, selected)
  end

  def fund_sector_menu(selected)
    secs = Fund::SECTORS.map { |sec| [sec, sec] }
    secs.unshift [t("select"), ""]
    options_for_select(secs, selected)
  end

  def fund_stars_menu(selected)
    stars = Fund::STARS.map { |star| [t("fund.stars.#{star}"), star] }
    options_for_select(stars, selected)
  end
end
