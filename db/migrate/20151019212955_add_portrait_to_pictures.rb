class AddPortraitToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :portrait, :boolean, default: false
  end
end
