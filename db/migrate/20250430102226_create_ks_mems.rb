class CreateKsMems < ActiveRecord::Migration[8.0]
  def change
    create_table :ks_mems do |t|
      t.string   :server, limit: 3
      t.datetime :measured_at
      t.integer  :total, :used, :free, :avail, :swap_used, :swap_free
    end

    add_index :ks_mems, [:measured_at, :server], unique: true
  end
end
