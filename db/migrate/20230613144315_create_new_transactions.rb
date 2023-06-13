class CreateNewTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.date     :date
      t.string   :category, limit: Transaction::MAX_CATEGORY
      t.string   :description, limit: Transaction::MAX_DESCRIPTION
      t.decimal  :amount, :balance, precision: 8, scale: 2
      t.string   :account, limit: Transaction::MAX_ACCOUNT

      t.timestamps
    end
  end
end
