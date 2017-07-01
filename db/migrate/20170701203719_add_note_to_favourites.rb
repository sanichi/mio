class AddNoteToFavourites < ActiveRecord::Migration[5.1]
  def change
    add_column :favourites, :note, :string, limit: Favourite::MAX_NOTE
  end
end
