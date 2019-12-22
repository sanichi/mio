class UnlinkMisas < ActiveRecord::Migration[6.0]
  def up
    Misa.all.each { |m| m.update_column(:note, m.unlink_vocabs(m.note))}
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
