class MassGraphData
  attr_reader :full_height, :data_rows, :date_window, :mass_window, :mass_ticks

  def initialize
    @data = Mass.order(:date).to_a
    @full_height = 500
    get_date_window
    get_mass_window
    get_data_rows
  end

  def date_title
    "'#{I18n.t("mass.date")}'".html_safe
  end

  def mass_title
    "'#{I18n.t("mass.mass")} (#{I18n.t("mass.unit.kg")})'".html_safe
  end

  def gridlines
    "{ count: -1, units: { months: { format: ['MMM'] } } }".html_safe
  end

  def minor_gridlines
    "{ count: -1, units: { days: { format: ['d'] } } }".html_safe
  end

  private

  def get_date_window
    if @data.any?
      min = @data.first.date.beginning_of_month
      max = @data.last.date.end_of_month.days_since(1)
    else
      min = Date.today.beginning_of_month
      max = Date.today.end_of_month.days_since(1)
    end
    @date_window = "{ min: #{chart_date(min)}, max: #{chart_date(max)} }".html_safe
  end

  def get_mass_window
    if @data.any?
      masses = @data.map{ |mass| [mass.start, mass.finish] }.flatten.compact
      min = masses.min
      max = masses.max
    else
      min = Mass::MIN_KG
      max = Mass::MAX_KG
    end
    delta = 5.0
    min = (min / delta).floor
    max = (max / delta).ceil
    @mass_ticks = "[#{min.upto(max).map { |t| t * delta.to_i }. join(', ')}]"
    @mass_window = "{ min: #{format "%.1f", min * delta}, max: #{format "%.1f", max * delta} }".html_safe
  end

  def get_data_rows
    # The numerical data.
    @data_rows = @data.map do |mass|
      %Q/  [#{ chart_date(mass.date) }, #{ mass.start || "null" }, #{ mass.finish || "null" }],/.html_safe
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
