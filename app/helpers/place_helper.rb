module PlaceHelper
  def place_category_menu(place)
    opts = Place::CATS.keys.map{ |c| [t("place.categories.#{c}"), c] }
    options_for_select(opts, place.category)
  end
end
