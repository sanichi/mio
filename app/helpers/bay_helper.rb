module BayHelper
  def bay_owner_menu(bay)
    own = Resident.by_name.map { |r| [r.name, r.id] }
    own.unshift [t("unknown"), ""]
    options_for_select(own, bay.resident_id)
  end

  def bay_search_menu(bay_id)
    bays = Bay.by_number.map { |b| [b.name, b.id] }
    bays.unshift [t("bay.any"), ""]
    options_for_select(bays, bay_id)
  end

  def bay_menu
    bays = Bay.by_number.map { |b| [b.name, b.id] }
    bays.unshift [t("select"), ""]
    options_for_select(bays)
  end
end
