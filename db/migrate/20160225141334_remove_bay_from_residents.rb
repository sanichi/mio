class RemoveBayFromResidents < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :residents do |t|
        dir.up do
          t.remove :bay
        end

        dir.down do
          t.integer :bay, limit: 1, default: 0
        end
      end
    end
  end
end
