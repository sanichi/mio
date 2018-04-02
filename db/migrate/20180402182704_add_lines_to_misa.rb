class AddLinesToMisa < ActiveRecord::Migration[5.1]
  def change
    add_column :misas, :lines, :integer, limit: 2, default: 0
  end
end
