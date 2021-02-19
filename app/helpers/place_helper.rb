module PlaceHelper
  def place_category_menu(place)
    opts = Place::CATS.keys.map{ |c| [t("place.categories.#{c}"), c] }
    options_for_select(opts, place.category)
  end

  def place_category_search_menu(selected)
    opts = Place::CATS.keys.map{ |c| [t("place.categories.#{c}"), c] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end

  def place_order_menu(selected)
    opts = [["by name", "ename"], ["by population", "pop"]]
    options_for_select(opts, selected)
  end

  def place_kanji_menu(selected)
    opts = Place.pluck(:jname)
                .join("")
                .split("")
                .tally
                .select{ |k,v| v > 1 && !k.match?(/市|地|方|県/)}
                .sort_by{ |k, v| v }
                .reverse
                .map{|p| ["#{p.first} (#{p.last})", p.first]}
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end


  def place_region_menu(place)
    # what are the appropriate categories of any regions to which this place could belong
    if place.category.present?
      level_above = Place::CATS[place.category] - 1
      if level_above < 0
        cats = []
      else
        cats = Place::CATS.select{ |k,v| v == level_above }.keys
      end
    else
      max = Place::CATS.values.max
      cats = Place::CATS.select{ |k,v| v < max }.keys
    end

    # given those categories, what are the actual regions to which this could belomng
    if cats.empty?
      opts = []
    else
      opts = Place.by_ename.where(category: cats).map{ |p| [p.jname, p.id] }
    end
    opts.unshift [t("none"), 0]

    options_for_select(opts, place.region_id)
  end
end
