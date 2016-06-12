class AddDoneToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :done, :boolean, default: false
  end
end
