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
    fans =
    [
      [t("favourite.any_fan"), ""],
      [t("favourite.mark"),   "m"],
      [t("favourite.sandra"), "s"],
    ]
    options_for_select(fans, fan)
  end

  def favourite_vote_menu(vote)
    votes = t("favourite.votes").each_with_index.map { |v, i| [v, i] }
    options_for_select(votes, vote)
  end
end
