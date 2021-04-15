class AddCoordinatesToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :mark_position, :string, limit: 10
    add_column :places, :text_position, :string, limit: 10
  end
end
