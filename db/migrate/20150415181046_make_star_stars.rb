class MakeStarStars < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :funds do |t|
        dir.up do
          t.string :stars
          t.remove :star
        end

        dir.down do
          t.string :star, :string, limit: 10
          t.remove :stars
        end
      end
    end
  end
end
