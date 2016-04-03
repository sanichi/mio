class ParkingData
  attr_reader :entries, :full

  BAY  = I18n.t("flat.bay")
  FLAT = I18n.t("flat.flat")
  NOD  = I18n.t("no_data")
  SEP  = I18n.t("symbol.separator")

  def initialize(full)
    @full = !!full
    @entries = @full ? 5 : 0;  # how many text entries in the value for each bay
    @any = @entries > 0;       # any entries at all?
  end

  def any?
    @any
  end

  def bay
    # Get raw data from the DB.
    reg = Vehicle.pluck(:id, :registration).each_with_object({}) do |(vid, reg), hash|
      hash[vid] = reg
    end
    fbs = Flat.all.each_with_object({}) do |flat, hash|
      hash[flat.bay] = "#{FLAT} #{flat.address} #{BAY} #{flat.bay}"
    end
    park = Parking.pluck(:bay, :vehicle_id).each_with_object({}) do |(bid, vid), hash|
      hash[bid] ||= Hash.new(0)
      hash[bid][vid] += 1
    end

    # Transform the parking data into a more useful form.
    park.each do |bid, count|
      total = count.values.sum
      vids  = count.keys.sort { |a, b| count[b] <=> count[a] }
      array = []
      (0..3).each do |i|
        vid = vids[i]
        if vid
          if i == 3 && vids[i + 1]
            others = vids.size - 3
            parkings = vids.slice(-others, others).map{ |vid| count[vid] }.sum
            text = remaining_count(others, parkings, total)
          else
            text = normal_count(reg[vid], count[vid], total)
          end
        else
          text = ''
        end
        array.push text
      end
      park[bid] = array
    end

    # Finally, build and return the output data structure.
    fbs.each_with_object({}) do |(bid, fb), hash|
      entries = []
      if full
        entries.push fb
        if park[bid]
          entries.push *park[bid]
        else
          entries.push "%s %s" % [SEP, NOD]
          (@entries - 2).times { entries.push '' }
        end
      end
      hash[bid] = entries
    end
  end

  private

  def normal_count(reg, count, total)
    frmt = "%s %s - %d (%d%%)"
    vals = [SEP, reg, count, (100.0 * count / total).round]
    frmt % vals
  end

  def remaining_count(number, count, total)
    frmt = "%s %d %s%s: %d (%d%%)"
    vals = [SEP, number, "other", number == 1 ? "" : "s", count, (100.0 * count / total).round]
    frmt % vals
  end
end
