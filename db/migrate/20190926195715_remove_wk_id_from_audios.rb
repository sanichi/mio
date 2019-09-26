class RemoveWkIdFromAudios < ActiveRecord::Migration[6.0]
  def up
    remove_column :wk_audios, :wk_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
