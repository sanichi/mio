class AddParentsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :father_id, :integer, limit: 3
    add_column :people, :mother_id, :integer, limit: 3
  end
end
