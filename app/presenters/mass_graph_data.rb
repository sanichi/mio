class MassGraphData
  attr_reader :full_height, :data_rows, :date_window, :mass_window, :mass_ticks, :start, :start_options

  def initialize(unit, start)
    @unit = unit
    @start = start
    @data = Mass.order(:date).to_a
    @full_height = 500
    get_start_options
    get_start
    get_date_window
    fix_missing_data
    get_mass_window
    get_data_rows
  end

  def date_title
    "'#{I18n.t("mass.date")}'".html_safe
  end

  def mass_title
    "'#{@unit.name}'".html_safe
  end

  def gridlines
    "{ count: -1, units: { months: { format: ['MMM'] } } }".html_safe
  end

  def minor_gridlines
    "{ count: -1, units: { days: { format: ['d'] } } }".html_safe
  end

  private

  def get_start_options
    @start_options = Array.new
    @start_options.push [I18n.t("mass.options.month"), 1]
    if @data.any?
      1.upto(Float::INFINITY) do |p|
        n = 2**p
        break if Date.today.months_ago(n) < @data.first.date
        @start_options.push [I18n.t("mass.options.months", months: n), n]
      end
      @start_options.push [I18n.t("all"), 0]
    end
  end

  def get_start
    @start = @start.to_i
    @start = 1 unless @start_options.map{ |option| option.last }.include?(@start)
  end

  def get_date_window
    if @data.any?
      if start == 0
        min = @data.first.date.days_ago(1)
        max = @data.last.date.days_since(1)
      else
        min = Date.today.months_ago(start)
        max = Date.today.days_since(1)
        @data.reject! { |mass| mass.date < min }
      end
    else
      min = Date.today.beginning_of_month
      max = Date.today.end_of_month.days_since(1)
    end
    @date_window = "{ min: #{chart_date(min)}, max: #{chart_date(max)} }".html_safe
  end

  def fix_missing_data
    starts = @data.map(&:start).compact
    finishes = @data.map(&:finish).compact
    if starts.any? && finishes.empty?
      @data[-1].finish = starts.last
    elsif finishes.any? && starts.empty?
      @data[-1].start = finish.last
    end
  end

  def get_mass_window
    masses = @data.map{ |mass| [@unit.to_f(mass.start), @unit.to_f(mass.finish)] }.flatten.compact
    masses = [70.0, 100.0] if masses.empty?
    ticks = @unit.ticks(masses.min, masses.max)
    @mass_ticks = "[#{ticks.join(', ')}]"
    @mass_window = "{ min: #{ticks[0]}, max: #{ticks[-1]} }".html_safe
  end

  def get_data_rows
    # The numerical data.
    @data_rows = @data.map do |mass|
      %Q/  [#{ chart_date(mass.date) }, #{ @unit.to_f(mass.start) || "null" }, #{ @unit.to_f(mass.finish) || "null" }],/.html_safe
    end

    # The header row.
    @data_rows.unshift %Q/  [{type: 'date', label: '#{ I18n.t("mass.date") }'}, '#{ I18n.t("mass.start") }', '#{ I18n.t("mass.finish") }'],/.html_safe

    # Omitt the comma of the last row.
    @data_rows[-1][-1] = ""
  end

  def chart_date(date)
    "'Date(#{date.year}, #{date.month - 1}, #{date.day})'".html_safe
  end
end
