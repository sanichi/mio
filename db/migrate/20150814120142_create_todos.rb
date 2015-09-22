class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string   :description, limit: Todo::MAX_DESC
      t.boolean  :done, default: false
      t.integer  :priority, limit: 1, default: Todo::PRIORITIES.first

      t.timestamps null: false
    end
  end
end
