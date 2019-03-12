class CreateProblems < ActiveRecord::Migration[5.2]
  def change
    create_table :problems do |t|
      t.integer  :category, limit: 1
      t.integer  :level, limit: 1
      t.text     :note
      t.integer  :subcategory, limit: 1

      t.timestamps null: false
    end
  end
end
