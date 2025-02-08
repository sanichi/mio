class DumpProblemsAndQuestions < ActiveRecord::Migration[8.0]
  def up
    drop_table :problems
    drop_table :questions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
