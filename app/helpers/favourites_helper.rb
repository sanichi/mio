module FavouritesHelper
  def favourite_category_menu(favourite)
    cats = t("favourite.categories").each_with_index.map { |cat, i| [cat, i] }
    cats.unshift [t("select"), ""] if favourite.new_record?
    options_for_select(cats, favourite.category)
  end

  def favourite_category_search_menu(category)
    cats = t("favourite.categories").each_with_index.map { |cat, i| [cat, i] }
    cats.unshift [t("favourite.any_category"), ""]
    options_for_select(cats, category)
  end

  def favourite_score_menu(selected, new_record)
    scores = (Favourite::MIN_SCORE..Favourite::MAX_SCORE).to_a.map do |s|
      txt = s == 0 ? t("favourite.not_applicable") : s.to_s
      num = s
      [txt, num]
    end
    scores.unshift [t("select"), ""] if new_record
    options_for_select(scores, selected)
  end

  def favourite_order_menu(selected)
    fans = %w/combo sandra mark year entered/.map{ |o| [t("favourite.order.#{o}"), o] }
    options_for_select(fans, selected)
  end
end
