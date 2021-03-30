class AddNotesToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :notes, :text
  end
end
