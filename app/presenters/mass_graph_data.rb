class MassGraphData
  attr_reader :full_height, :data_rows, :date_window, :mass_window, :mass_ticks

  def initialize(unit)
    @unit = unit
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
    "'#{@unit.name}'".html_safe
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
    masses = @data.map{ |mass| [@unit.to_f(mass.start), @unit.to_f(mass.finish)] }.flatten.compact
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
