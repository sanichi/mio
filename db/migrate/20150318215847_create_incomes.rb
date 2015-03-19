class CreateIncomes < ActiveRecord::Migration
  def change
    create_table :incomes do |t|
      t.decimal  :amount, precision: 10, scale: 2
      t.string   :category, limit: 10
      t.string   :description, limit: 60
      t.string   :period, limit: 10
      t.date     :start, :finish

      t.timestamps null: false
    end
  end
end
