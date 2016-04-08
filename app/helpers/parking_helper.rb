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

  def guess_next_parking(parkings)
    bays = parkings.each_with_object(Hash.new(0)) do |p, h|
      h[p.bay] += 1
    end.sort_by { |bay, count| count }
    vids = parkings.each_with_object(Hash.new(0)) do |p, h|
      h[p.vehicle_id] += 1
    end.sort_by { |vid, count| count }

    # If all the same bays (vehicles), guess that plus the most popular vehicle (bay).
    # Otherwise, don't try to guess.
    bay, vehicle = bays.size == 1 || vids.size == 1 ? [bays.last.first, vids.last.first] : [nil, nil]
    new_parking_path(bay: bay, vehicle: vehicle)
  end
end
