class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string   :description, limit: Todo::MAX_DESC
      t.boolean  :done, default: false
      t.integer  :priority, limit: 1, default: 0

      t.timestamps null: false
    end
  end
end
