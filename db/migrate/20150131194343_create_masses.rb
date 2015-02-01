class CreateMasses < ActiveRecord::Migration
  def change
    create_table :masses do |t|
      t.date     :date
      t.decimal  :start, :finish, precision: 4, scale: 1

      t.timestamps null: false
    end
  end
end
