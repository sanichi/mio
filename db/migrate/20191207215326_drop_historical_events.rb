class DropHistoricalEvents < ActiveRecord::Migration[6.0]
  def up
    drop_table :historical_events
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
