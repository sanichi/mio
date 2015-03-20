class IncomeGraphData
  attr_reader :full_height, :data_rows, :years, :incomes

  def initialize
    @data = Income.order(:description, :category).to_a
    @full_height = 500
    get_years
    get_incomes
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

  def get_years
    min = 2014
    max = 2023
    @years = (min..max).to_a
  end

  def get_incomes
    @incomes = @years.map do |year|
      cut = Date.new(year, 7, 1)
      @data.map do |income|
        if (income.start && income.start >= cut) || (income.finish && income.finish < cut)
          0
        else
          income.annual
        end
      end
    end
  end

  def get_data_rows
    # The numerical data.
    @data_rows = @incomes.each_with_index.map do |yearly_incomes, i|
      %Q/  ['#{ @years[i] }', #{ yearly_incomes.join(", ") }],/.html_safe
    end

    # The header row.
    @data_rows.unshift %Q/  ['Year', #{@data.map { |i| "'#{i.full_description}'" }.join(", ")}],/.html_safe

    # Omitt the comma of the last row.
    @data_rows[-1][-1] = ""
  end

  def get_mass_window
    masses = @data.map{ |mass| [@unit.to_f(mass.start), @unit.to_f(mass.finish)] }.flatten.compact
    ticks = @unit.ticks(masses.min, masses.max)
    @mass_ticks = "[#{ticks.join(', ')}]"
    @mass_window = "{ min: #{ticks[0]}, max: #{ticks[-1]} }".html_safe
  end

  def chart_date(date)
    "'Date(#{date.year}, #{date.month - 1}, #{date.day})'".html_safe
  end
end
