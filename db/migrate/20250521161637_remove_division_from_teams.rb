class RemoveDivisionFromTeams < ActiveRecord::Migration[8.0]
  def up
    remove_column :teams, :division
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
