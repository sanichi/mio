class RemoveOldMisaUrls < ActiveRecord::Migration[6.0]
  def up
    remove_column :misas, :long, :string
    remove_column :misas, :short, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
