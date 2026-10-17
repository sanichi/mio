class AddIndexesToWkAudiosAndTransactions < ActiveRecord::Migration[8.1]
  def change
    add_index :wk_audios, [:audible_type, :audible_id]
    add_index :transactions, :upload_id
  end
end
