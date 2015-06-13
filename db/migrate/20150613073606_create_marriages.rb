class CreateMarriages < ActiveRecord::Migration
  def change
    create_table :marriages do |t|
      t.integer :divorce, limit: 2
      t.integer :husband_id
      t.integer :wedding, limit: 2
      t.integer :wife_id

      t.timestamps null: false
    end
  end
end
