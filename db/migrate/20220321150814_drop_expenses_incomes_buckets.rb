class DropExpensesIncomesBuckets < ActiveRecord::Migration[7.0]
  def up
    drop_table :buckets
    drop_table :expenses
    drop_table :incomes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
