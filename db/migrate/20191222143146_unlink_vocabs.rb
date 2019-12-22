class UnlinkVocabs < ActiveRecord::Migration[6.0]
  def up
    Wk::Vocab.all.each { |v| v.update_column(:notes, v.unlink_vocabs(v.notes))}
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
