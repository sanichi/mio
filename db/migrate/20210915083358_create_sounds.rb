class CreateSounds < ActiveRecord::Migration[6.1]
  def change
    create_table :sounds do |t|
      t.string   :category, limit: 8
      t.string   :name, limit: 100
      t.integer  :level, limit: 1, default: 5
      t.text     :note

      t.timestamps
    end
  end
end
