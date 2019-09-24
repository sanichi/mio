class FinishMovingAudiosFromVocabs < ActiveRecord::Migration[6.0]
  def up
    remove_index  :wk_audios, :vocab_id
    remove_column :wk_audios, :vocab_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
