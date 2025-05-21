class RemoveSlugFromTeams < ActiveRecord::Migration[8.0]
  def up
    remove_column :teams, :slug
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
