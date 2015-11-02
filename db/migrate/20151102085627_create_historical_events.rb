class CreateHistoricalEvents < ActiveRecord::Migration
  def change
    create_table :historical_events do |t|
      t.integer  :start, limit: 2
      t.integer  :finish, limit: 2
      t.string   :description, limit: HistoricalEvent::MAX_DESC

      t.timestamps null: false
    end
  end
end
