class CreateStars < ActiveRecord::Migration[7.1]
  def change
    create_table :stars do |t|
      t.string   :name, limit: Star::MAX_NAME
      t.integer  :distance, limit: 3
      t.text     :note

      t.timestamps
    end
  end
end
