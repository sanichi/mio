class DeleteConstellationFromStars < ActiveRecord::Migration[7.1]
  def up
    remove_column :stars, :constellation
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
