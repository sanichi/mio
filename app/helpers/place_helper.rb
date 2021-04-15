module PlaceHelper
  def place_category_menu(place)
    opts = Place::CATS.keys.map{ |c| [t("place.categories.#{c}"), c] }
    options_for_select(opts, place.category)
  end

  def place_category_search_menu(selected)
    opts = Place::CATS.keys.map{ |c| [t("place.categories.#{c}", locale: "jp"), c] }
    opts.unshift [t("all", locale: "jp"), ""]
    opts.push [t("place.categories.cities", locale: "jp"), "cities"]
    options_for_select(opts, selected)
  end

  def place_order_menu(selected)
    opts = [[t("place.ename", locale: "jp"), "ename"], [t("place.pop", locale: "jp"), "pop"]]
    options_for_select(opts, selected)
  end

  def place_kanji_menu(selected)
    opts = Place.pluck(:jname)
                .map{ |n| n.sub(/(地方|県|府|都|市|特別区)\z/, "") }
                .uniq
                .join("")
                .split("")
                .tally
                .select{ |k,v| v > 1 }
                .sort_by{ |k,v| v }
                .reverse
                .map{ |k,v| ["#{k} (#{v})", k] }
    opts.unshift [t("all", locale: "jp"), ""]
    options_for_select(opts, selected)
  end


  def place_parent_menu(place)
    # what are the appropriate categories of any parents to which this place could belong
    if place.category.present?
      level_above = Place::CATS[place.category] - 1
      if level_above < 0
        cats = []
      elsif level_above == 2
        cats = Place::CATS.select{ |k,v| v == 2 || v == 1 }.keys
      else
        cats = Place::CATS.select{ |k,v| v == level_above }.keys
      end
    else
      max = Place::CATS.values.max
      cats = Place::CATS.select{ |k,v| v < max }.keys
    end

    # given those categories, what are the actual parents to which this could belomng
    if cats.empty?
      opts = []
    else
      opts = Place.by_ename.where(category: cats).map{ |p| [p.jname, p.id] }
    end
    opts.unshift [t("none"), 0]

    options_for_select(opts, place.parent_id)
  end
end
