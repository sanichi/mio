class TransactionSummary
  def initialize
    @items = Hash.new { |hash, description| hash[description] = Item.new(description) }

    Transaction.order(:description, :trade_date).each do |transaction|
      item = @items[transaction.description]
      item.add(transaction)
    end
  end

  def items
    @items.values
  end

  class Item
    attr_reader :description, :value, :quantity, :start_date, :end_date

    def initialize(description)
      @description = description
      @value = 0.0
      @quantity = nil
    end

    def add(transaction)
      @value+= transaction.value
      if transaction.account == "cap"
        if transaction.quantity.present?
          @quantity ||= 0
          if transaction.value < 0.0
            @quantity+= transaction.quantity # buy
          else
            @quantity-= transaction.quantity # sell
          end
        end
        @initial_value = -transaction.value if @initial_value.blank?
      end
      date = transaction.trade_date
      @start_date = date if @start_date.blank? || @start_date > date
      @end_date = date if @end_date.blank? || @end_date < date
    end

    def performance
      return nil unless quantity == 0 && @initial_value && @initial_value != 0.0
      Rails.logger.info [description, quantity, value.to_f, @initial_value.to_f]
      @performance ||= 100.0 * value / @initial_value
    end

    def annual_performance
      return nil unless performance && @start_date && @end_date
      @annual_performance ||= 365.0 * performance / (@end_date - @start_date).to_i
    end
  end
end
