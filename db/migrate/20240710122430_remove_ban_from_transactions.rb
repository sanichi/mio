class RemoveBanFromTransactions < ActiveRecord::Migration[7.1]
  def change
    remove_column :transactions, :ban, :integer, limit: 3, default: 0
  end
end
