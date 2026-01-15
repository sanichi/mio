class AddScale2ToMasses < ActiveRecord::Migration[8.1]
  def change
    add_column :masses, :start_2, :decimal, precision: 4, scale: 1
    add_column :masses, :finish_2, :decimal, precision: 4, scale: 1
  end
end
