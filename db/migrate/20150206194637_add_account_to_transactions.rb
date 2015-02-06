class AddAccountToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :account, :string, limit: 3
  end
end
