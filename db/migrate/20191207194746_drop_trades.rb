class DropTrades < ActiveRecord::Migration[6.0]
  def up
    drop_table :trades
    drop_table :funds
    drop_table :transactions
    drop_table :uploads
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
