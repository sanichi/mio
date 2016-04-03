class ParkingData
  attr_reader :bay
  attr_reader :entries

  def initialize(full)
    @entries = full ? 1 : 0;

    # Get the raw data we need from DB.
    reg = Vehicle.pluck(:id, :registration).each_with_object({}) do |(vid, reg), hash|
      hash[vid] = reg
    end
    flat = Flat.order(:bay).pluck(:bay, :building, :number).each_with_object({}) do |(bid, bld, flat), hash|
      hash[bid] = "Flat #{bld}#{flat ? '/' + flat.to_s : ''} Bay #{bid}"
    end

    # Build and return the parking bay data.
    @bay = flat.each_with_object({}) do |(bid, flat), hash|
      entries = []
      if full
        entries.push flat
      end
      hash[bid] = entries
    end
  end
end
