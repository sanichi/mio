class LengthenFavouriteLink < ActiveRecord::Migration[5.1]
  def up
    change_column :favourites, :link, :string, limit: Favourite::MAX_LINK
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
