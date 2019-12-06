class DropBlogs < ActiveRecord::Migration[6.0]
  def up
    drop_table :blogs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
