class UnlinkNotes < ActiveRecord::Migration[6.0]
  def up
    Note.all.each { |n| n.update_column(:stuff, n.unlink_vocabs(n.stuff))}
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
