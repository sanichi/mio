class DropLessons < ActiveRecord::Migration[8.0]
  def up
    drop_table :lessons
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
