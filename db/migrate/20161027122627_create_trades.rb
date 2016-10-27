class CreateTrades < ActiveRecord::Migration[5.0]
  def change
    create_table :trades do |t|
      t.string   :stock, limit: Trade::MAX_STOCK
      t.decimal  :units, precision: 10, scale: 3
      t.decimal  :buy_price, precision: 9, scale: 2
      t.decimal  :sell_price, precision: 9, scale: 2
      t.date     :buy_date
      t.date     :sell_date

      t.timestamps null: false
    end
  end
end
