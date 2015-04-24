module FundHelper
  def fund_category_menu(fund)
    cats = Fund::CATEGORIES.map { |cat| [t("fund.category.#{cat}"), cat] }
    cats.unshift [t("select"), ""] if fund.new_record?
    options_for_select(cats, fund.category)
  end

  def fund_sector_menu(fund)
    secs = Fund::SECTORS.map { |sec| [sec, sec] }
    secs.unshift [t("select"), ""] if fund.new_record?
    options_for_select(secs, fund.sector)
  end

  def fund_srri_menu(fund)
    srris = (Fund::MIN_SRRI..Fund::MAX_SRRI).map { |srri| [srri, srri] }
    srris.unshift [t("select"), ""] if fund.new_record?
    options_for_select(srris, fund.srri)
  end

  def fund_stars_menu(fund)
    stars = Fund::STARS.map { |star| [t("fund.stars.#{star}"), star] }
    options_for_select(stars, fund.stars)
  end
end
