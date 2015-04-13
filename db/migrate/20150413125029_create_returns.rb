class CreateReturns < ActiveRecord::Migration
  def change
    create_table :returns do |t|
      t.integer    :year, limit: 1
      t.decimal    :percent, precision: 4, scale: 1
      t.references :returnable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
