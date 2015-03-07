class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.decimal  :amount, precision: 10, scale: 2
      t.string   :category, limit: 10
      t.string   :description, limit: 30
      t.string   :period, limit: 10
      
      t.timestamps null: false
    end
  end
end
