class CreateKsTops < ActiveRecord::Migration[8.0]
  def change
    create_table :ks_tops do |t|
      t.string   :server, limit: 3
      t.datetime :measured_at
    end

    add_index :ks_tops, [:measured_at, :server], unique: true
  end
end
