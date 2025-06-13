class CreateMassEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :mass_events do |t|
      t.string   :name, limit: 24
      t.date     :start, :finish

      t.timestamps
    end
  end
end
