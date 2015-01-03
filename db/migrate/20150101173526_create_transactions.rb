class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.decimal  :cost, precision: 10, scale: 2
      t.datetime :created_at
      t.string   :description
      t.integer  :quantity
      t.string   :reference
      t.date     :settle_date
      t.string   :signature
      t.date     :trade_date
      t.integer  :upload_id
      t.decimal  :value, precision: 10, scale: 2
    end
    
    add_index :transactions, :upload_id
    add_index :transactions, :signature, unique: true
  end
end
