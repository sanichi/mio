class RenameRegionId < ActiveRecord::Migration[6.1]
  def change
    rename_column :places, :region_id, :parent_id
  end
end
