class TransactionSummary
  def initialize
    @items = Hash.new { |hash, description| hash[description] = Item.new(description) }

    Transaction.order(:description).each do |transaction|
      item = @items[transaction.description]
      item.add(transaction)
    end
  end

  def items
    @items.values
  end

  class Item
    attr_reader :description, :value, :quantity

    def initialize(description)
      @description = description
      @value = 0.0
      @quantity = nil
    end

    def add(transaction)
      @value+= transaction.value
      if transaction.quantity.present?
        @quantity ||= 0
        if transaction.value < 0.0
          @quantity+= transaction.quantity # buy
        else
          @quantity-= transaction.quantity # sell
        end
      end
    end
  end
end
