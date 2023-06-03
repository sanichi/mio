class DeleteReadingIdFromAudios < ActiveRecord::Migration[7.0]
  def up
    remove_column :wk_audios, :reading_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
