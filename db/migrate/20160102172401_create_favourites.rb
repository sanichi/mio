class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      t.integer  :category, limit: 1
      t.string   :fans, limit: Favourite::MAX_FANS
      t.string   :name, limit: Favourite::MAX_NAME
      t.string   :link, limit: Favourite::MAX_LINK
      t.integer  :year

      t.timestamps null: false
    end
  end
end
