class CreateFunds < ActiveRecord::Migration
  def change
    create_table :funds do |t|
      t.decimal  :annual_fee, precision: 2, scale: 1
      t.string   :category, limit: 10
      t.string   :company, :name, limit: 50
      t.boolean  :performance_fee
      t.integer  :risk_reward_profile, limit: 1

      t.timestamps null: false
    end
  end
end
