class AddViewboxToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :vbox, :string, limit: 20
  end
end
