class ParkingData
  attr_reader :pdata

  def initialize
    # Get the raw data we need from DB.
    reg = Vehicle.pluck(:id, :registration).each_with_object({}) do |(vid, reg), hash|
      hash[vid] = reg
    end
    flat = Flat.order(:bay).pluck(:bay, :building, :number).each_with_object({}) do |(bid, bld, flat), hash|
      hash[bid] = "Bay #{bid} Flat #{bld}#{flat ? '-' + flat.to_s : ''}"
    end

    # Build and return the parking data.
    @pdata = flat.each_with_object({}) do |(bid, flat), hash|
      hash[bid] = [flat]
    end
  end
end
