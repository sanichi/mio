class ChangeUsersPartB < ActiveRecord::Migration[6.0]
  def up
    remove_column :users, :person_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
