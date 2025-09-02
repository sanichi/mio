class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.string :payee
      t.integer :amount
      t.integer :frequency, default: 12, limit: 2
      t.string :source

      t.timestamps
    end
  end
end
