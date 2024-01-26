class CreateConstellations < ActiveRecord::Migration[7.1]
  def change
    create_table :constellations do |t|
      t.string   :name, limit: Constellation::MAX_NAME
      t.string   :iau, limit: Constellation::MAX_IAU
      t.text     :note

      t.timestamps
    end
  end
end
