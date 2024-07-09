class AddBanToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :ban, :integer, limit: 3, default: 0
  end
end
