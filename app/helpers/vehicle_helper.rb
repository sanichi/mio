module VehicleHelper
  def vehicle_owner_menu(vehicle)
    own = Resident.by_name.map { |r| [r.name, r.id] }
    own.unshift [t("unknown"), ""]
    options_for_select(own, vehicle.resident_id)
  end
end
