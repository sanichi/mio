class CreateTests < ActiveRecord::Migration[6.1]
  def change
    create_table :tests do |t|
      t.bigint   :testable_id
      t.string   :testable_type
      t.integer  :attempts, :poor, :fair, :good, :excellent, limit: 2, default: 0
      t.integer  :level, limit: 1, default: 0
      t.datetime :due

      t.timestamps
    end

    add_index :tests, [:testable_type, :testable_id]
  end
end
