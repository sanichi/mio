class AddFactorToTrades < ActiveRecord::Migration[5.0]
  def change
    add_column :trades, :buy_factor, :decimal, precision: 6, scale: 3, default: 1.0
    add_column :trades, :sell_factor, :decimal, precision: 6, scale: 3, default: 1.0
  end
end
