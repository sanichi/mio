class ParkingStat
  attr_reader :headers, :data

  MONTHS = [0, 12, 6, 3, 1]
  NUMBERS = [10, 20, 30]
  STATS = I18n.t("pages.risle.stats").keys.map(&:to_s)

  def initialize(any, params={})
    @any = any
    @stat = STATS.include?(params[:stat]) ? params[:stat] : STATS.first
    @number = NUMBERS.include?(params[:number].to_i) ? params[:number].to_i : NUMBERS.first
    @months = MONTHS.include?(params[:months].to_i) ? params[:months].to_i : MONTHS.first
    @data = get_data
  end

  def any?
    @any
  end

  private

  def get_data
    parkings = Parking.where("created_at #{@months == 0 ? 'IS NOT NULL' : '> ?'}", Time.now.months_ago(@months))
    case @stat
    when "lub", "mub"  # least/most used bay
      @headers = [I18n.t("flat.bay"), I18n.t("parking.parkings")]
      parkings = parkings.group(:bay).count
      Flat::BAYS.each { |b| parkings[b] = 0 unless parkings.has_key?(b) }
      bay_count_data(parkings)
    when "blv", "bmv"  # bays with least/most vehicles
      @headers = [I18n.t("flat.bay"), I18n.t("vehicle.vehicles"), I18n.t("parking.parkings")]
      parkings = parkings.group(:bay, :vehicle_id).count.each_with_object({}) do |((bay, vid), count), h|
        h[bay] ||= [0, 0]
        h[bay][0] += 1
        h[bay][1] += count
      end
      Flat::BAYS.each { |b| parkings[b] = [0, 0] unless parkings.has_key?(b) }
      bay_count_data(parkings.map{ |bay, counts| [bay, *counts] })
    when "vlb", "vmb"  # vehicles with least/most bays
      registration = Vehicle.pluck(:id, :registration).each_with_object({}){ |(vid, reg), h| h[vid] = reg }
      @headers = [I18n.t("vehicle.vehicles"), I18n.t("flat.bays"), I18n.t("parking.parkings")]
      parkings = parkings.group(:bay, :vehicle_id).count.each_with_object({}) do |((bay, vid), count), h|
        reg = registration[vid]
        h[reg] ||= [[], 0]
        h[reg][0].push bay
        h[reg][1] += count
      end
      vehicle_bays_data(parkings.map{|reg, (bays, count)| [reg, bays.sort, count]})
    end
  end

  def bay_count_data(stats)
    case @stat
    when "lub", "blv"  # least
      stats.sort{ |a, b| [a[1], a[2], a[0]] <=> [b[1], b[2], b[0]] }.first(@number)
    else  # most
      stats.sort{ |a, b| [b[1], b[2], a[0]] <=> [a[1], a[2], b[0]] }.first(@number)
    end.map do |bay, *count|
      [bay, *count.map(&:to_s)]
    end
  end

  def vehicle_bays_data(stats)
    case @stat
    when "vlb"  # least
      stats.sort{ |a, b| [a[1].size, a[2], a[0]] <=> [b[1].size, b[2], b[0]] }.first(@number)
    else  # most
      stats.sort{ |a, b| [b[1].size, b[2], a[0]] <=> [a[1].size, a[2], b[0]] }.first(@number)
    end.map do |reg, bays, count|
      [reg, bays, count.to_s]
    end
  end
end
