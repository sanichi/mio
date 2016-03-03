class CreateFlats < ActiveRecord::Migration
  def change
    create_table :flats do |t|
      t.integer  :bay, :block, :building, :number, limit: 1
      t.string   :name, limit: Flat::NAMES.map(&:length).max
      t.string   :category, limit: Flat::CATEGORIES.map(&:length).max
      t.integer  :owner_id, :tenant_id

      t.timestamps null: false
    end
  end
end
