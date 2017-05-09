class DropTaxes < ActiveRecord::Migration[5.1]
  def change
    drop_table :taxes
  end
end
