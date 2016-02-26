module VehicleHelper
  def vehicle_owner_menu(vehicle)
    own = Resident.by_name.map { |r| [r.name, r.id] }
    own.unshift [t("unknown"), ""]
    options_for_select(own, vehicle.resident_id)
  end

  def vehicle_search_menu(vehicle_id)
    cars = Vehicle.by_registration.map { |v| [v.registration, v.id] }
    cars.unshift [t("vehicle.any"), ""]
    options_for_select(cars, vehicle_id)
  end

  def vehicle_menu(vehicle_id)
    cars = Vehicle.by_registration.map { |v| [v.registration, v.id] }
    cars.unshift [t("select"), ""]
    options_for_select(cars, vehicle_id)
  end
end
