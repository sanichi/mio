class ParkingData
  attr_reader :entries

  BAY  = I18n.t("flat.bay")
  FLAT = I18n.t("flat.flat")
  NOD  = I18n.t("no_data")
  SEP  = I18n.t("symbol.separator")
  STR  = I18n.t("parking.street")

  def initialize
    # Set the number of lines of info per bay.
    @entries = 5
  end

  # Return a hash from bay numbers to arrays (max length 5) of vehicle parking data.
  def bay
    # Get raw data from the DB.
    reg = Vehicle.pluck(:id, :registration).each_with_object({}) do |(vid, reg), hash|
      hash[vid] = reg
    end
    fbs = {}
    fbs[0] = STR
    Flat.where.not(bay: nil).order(:bay).each do |flat|
      fbs[flat.bay] = "#{FLAT} #{flat.address} #{BAY} #{flat.bay}"
    end
    park = Parking.pluck(:bay, :vehicle_id).each_with_object({}) do |(bay, vid), hash|
      hash[bay] ||= Hash.new(0)
      hash[bay][vid] += 1
    end

    # Transform the parking data into a more useful form.
    park.each do |bay, count|
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
      park[bay] = array
    end

    # Finally, build and return the output data structure.
    fbs.each_with_object({}) do |(bay, fb), hash|
      entries = []
      entries.push fb
      if park[bay]
        entries.push *park[bay]
      else
        entries.push "%s %s" % [SEP, NOD]
        (@entries - 2).times { entries.push '' }
      end
      hash[bay] = entries
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
