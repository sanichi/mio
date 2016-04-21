class ParkingStats
  attr_reader :headers, :data

  MONTHS = [0, 12, 6, 3, 1]
  NUMBERS = [10, 20, 30]
  STATS = I18n.t("pages.risle.stats").keys.map(&:to_s)

  def initialize(any, params={})
    @any = !!any
    @stat = STATS.include?(params[:stat]) ? params[:stat] : STATS.first
    @number = NUMBERS.include?(params[:number].to_i) ? params[:number].to_i : NUMBERS.first
    @months = MONTHS.include?(params[:months].to_i) ? params[:months].to_i : MONTHS.first
    get_stats
  end

  def any?
    @any
  end

  private

  def get_stats
    parkings = Parking.where("created_at #{@months == 0 ? 'IS NOT NULL' : '> ?'}", Time.now.months_ago(@months))
    case @stat
    when "lub", "mub"  # least/most used bay
      @headers = [I18n.t("flat.bay"), I18n.t("parking.parkings")]
      parkings = parkings.group(:bay).count
      Flat::BAYS.each { |b| parkings[b] = 0 unless parkings.has_key?(b) }
      @data = bay_count_data(parkings)
    when "blv", "bmv"  # bays with least/most vehicles
      @headers = [I18n.t("flat.bay"), I18n.t("vehicle.vehicles")]
      parkings = parkings.group(:bay, :vehicle_id).count.keys.each_with_object(Hash.new(0)) do |(bay, vid), h|
        h[bay] += 1
      end
      Flat::BAYS.each { |b| parkings[b] = 0 unless parkings.has_key?(b) }
      @data = bay_count_data(parkings)
    when "vlb", "vmb"  # vehicles with least/most bays
      reg = Vehicle.pluck(:id, :registration).each_with_object({}){ |(vid, reg), h| h[vid] = reg }
      @headers = [I18n.t("vehicle.vehicles"), I18n.t("flat.bays")]
      parkings = parkings.group(:bay, :vehicle_id).count.keys.each_with_object(Hash.new{ |h,k| h[k] = [] }) do |(bay, vid), h|
        h[reg[vid]].push bay
      end
      parkings.values.each { |bays| bays.sort! }
      @data = vehicle_bays_data(parkings)
    end
  end

  def bay_count_data(stats)
    case @stat
    when "lub", "blv"  # least
      stats.sort{ |a, b| [a[1], a[0]] <=> [b[1], b[0]] }.first(@number)
    else  # most
      stats.sort{ |a, b| [b[1], a[0]] <=> [a[1], b[0]] }.first(@number)
    end.map do |bay, count|
      [bay, count.to_s]
    end
  end

  def vehicle_bays_data(stats)
    case @stat
    when "vlb"  # least
      stats.sort{ |a, b| [a[1].size, a[0]] <=> [b[1].size, b[0]] }.first(@number)
    else  # most
      stats.sort{ |a, b| [b[1].size, a[0]] <=> [a[1].size, b[0]] }.first(@number)
    end
  end
end
