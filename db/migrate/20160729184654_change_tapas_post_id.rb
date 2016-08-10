class ChangeTapasPostId < ActiveRecord::Migration[5.0]
  def up
    change_column :tapas, :post_id, :string, limit: Tapa::MAX_POST_ID
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
