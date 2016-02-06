class AddPostIdToTapas < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :tapas do |t|
        dir.up do
          t.integer :post_id
        end

        dir.down do
          t.remove :post_id
        end
      end
    end
  end
end
