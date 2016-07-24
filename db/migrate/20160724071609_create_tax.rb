class CreateTax < ActiveRecord::Migration[5.0]
  def change
    create_table :taxes do |t|
      t.string   :description, limit: Tax::MAX_DESC
      t.integer  :free, limit: 1
      t.integer  :income, limit: 2
      t.integer  :paid, limit: 2
      t.integer  :times, limit: 1, default: 1
      t.integer  :year_number, limit: 1

      t.timestamps null: false
    end
  end
end
