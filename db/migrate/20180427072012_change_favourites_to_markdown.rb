class ChangeFavouritesToMarkdown < ActiveRecord::Migration[5.2]
  def change
    change_column :favourites, :note, :text
  end
end
