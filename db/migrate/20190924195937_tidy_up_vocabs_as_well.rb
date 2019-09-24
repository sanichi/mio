class TidyUpVocabsAsWell < ActiveRecord::Migration[6.0]
  def up
    remove_column :wk_vocabs, :accent_pattern
    remove_column :wk_vocabs, :accent_position
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
