class RemoveAvailableFromBooks < ActiveRecord::Migration[5.2]
  def change
    remove_column :books, :available, :boolean, default: true
  end
end
