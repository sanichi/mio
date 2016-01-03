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

  def favourite_fan_search_menu(fan)
    fans = Favourite.pluck(:fans).reduce([]){ |c, f| c << f.scan(/[A-Z][a-z]+/) }.flatten.uniq.sort.map{ |f| [f, f] }
    fans.unshift [t("favourite.any_fan"), ""]
    options_for_select(fans, fan)
  end
end
