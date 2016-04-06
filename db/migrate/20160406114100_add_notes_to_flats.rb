class AddNotesToFlats < ActiveRecord::Migration
  def change
    add_column :flats, :notes, :text
  end
end
