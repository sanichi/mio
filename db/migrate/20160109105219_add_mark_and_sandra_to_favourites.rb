class AddMarkAndSandraToFavourites < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :favourites do |t|
        dir.up do
          t.integer :mark, default: 0, limit: 1
          t.integer :sandra, default: 0, limit: 1
          Favourite.all.each do |f|
            f.update_column(:mark, 1)   if f.fans.include?("Mark")
            f.update_column(:sandra, 1) if f.fans.include?("Sandra")
          end
        end

        dir.down do
          t.remove :mark
          t.remove :sandra
        end
      end
    end
  end
end
