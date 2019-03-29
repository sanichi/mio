class RemoveOldImageStuffFromPictures < ActiveRecord::Migration[5.2]
  def up
    remove_column :pictures, :image_file_name, :string
    remove_column :pictures, :image_content_type, :string
    remove_column :pictures, :image_file_size, :integer
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
