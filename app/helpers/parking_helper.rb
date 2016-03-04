module ParkingHelper
  def parking_bay_menu(bay, search: false)
    opt = Flat::BAYS.map { |b| [b, b] }
    opt.unshift [t("parking.street"), 0]
    if search
      opt.unshift [t("parking.any_bay"), ""]
    else
      opt.unshift [t("select"), ""]
    end
    options_for_select(opt, bay)
  end
end
