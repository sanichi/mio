class IncomeGraphData
  attr_reader :full_height, :data_rows, :years, :incomes

  def initialize(scope)
    @joint = scope != "total"
    @data = Income.graph_order.all
    @full_height = 500
    get_years
    get_incomes
    get_data_rows
  end

  def vaxis_label
    "#{I18n.t(@joint ? 'income.joint' : 'total')} #{I18n.t('income.income')}"
  end

  private

  def get_years
    @years = (Income::MIN_YEAR..Income::MAX_YEAR).to_a
  end

  def get_incomes
    @incomes = @years.map do |year|
      cut = Date.new(year, 7, 1)
      @data.map do |income|
        if (income.start && income.start >= cut) || (income.finish && income.finish < cut)
          0
        else
          income.annual(joint: @joint)
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
end
