class CreateKsBoots < ActiveRecord::Migration[8.0]
  def change
    create_table :ks_boots do |t|
      t.string   :server, limit: 3
      t.string   :app, limit: 6
      t.datetime :happened_at
    end

    add_index :ks_boots, [:happened_at, :server, :app], unique: true
  end
end
