class AddNotesToWkGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :wk_groups, :notes, :text
  end
end
