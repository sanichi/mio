class CreateBays < ActiveRecord::Migration
  def change
    create_table :bays do |t|
      t.integer  :number, limit: 1
      t.integer  :resident_id

      t.timestamps null: false
    end
  end
end
