class RemoveFansFromFavourites < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :favourites do |t|
        dir.up do
          t.remove :fans
        end

        dir.down do
          t.string :fans, limit: Favourite::MAX_FANS
          Favourite.all.each do |f|
            fans = []
            fans.push("Mark") if f.mark > 0
            fans.push("Sandra") if f.sandra > 0
            f.update_column(:fans, fans.join(", "))
          end
        end
      end
    end
  end
end
