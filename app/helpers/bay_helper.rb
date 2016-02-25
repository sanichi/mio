module BayHelper
  def bay_owner_menu(bay)
    own = Resident.by_name.map { |r| [r.name, r.id] }
    own.unshift [t("unknown"), ""]
    options_for_select(own, bay.resident_id)
  end
end
