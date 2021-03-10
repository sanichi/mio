module PlaceHelper
  def place_category_menu(place)
    opts = Place::CATS.keys.map{ |c| [t("place.categories.#{c}"), c] }
    options_for_select(opts, place.category)
  end

  def place_category_search_menu(selected)
    opts = Place::CATS.keys.map{ |c| [t("place.categories.#{c}"), c] }
    opts.unshift [t("all"), ""]
    opts.push [t("place.categories.cities"), "cities"]
    options_for_select(opts, selected)
  end

  def place_order_menu(selected)
    opts = [["by name", "ename"], ["by population", "pop"]]
    options_for_select(opts, selected)
  end

  def place_kanji_menu(selected)
    regs = Place.where(category: "region").pluck(:jname).map{ |n| n.delete_suffix("地方") }
    prfs = Place.where(category: "prefecture").pluck(:jname).map{ |n| n.sub(/(県|府|都)\z/, "") }
    cits = Place.where(category: "city").pluck(:jname).map{ |n| n.sub(/(市|特別区)\z/, "") }
    nams = regs + prfs + cits
    opts = nams.uniq
               .join("")
               .split("")
               .tally
               .select{ |k,v| v > 1 }
               .sort_by{ |k,v| v }
               .reverse
               .map{ |k,v| ["#{k} (#{v})", k] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end


  def place_parent_menu(place)
    # what are the appropriate categories of any parents to which this place could belong
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
