class AddUploadIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :upload_id, :integer
  end
end
