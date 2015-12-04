class RemovePersonIdFromPictures < ActiveRecord::Migration
  def change
    remove_column :pictures, :person_id
  end
end
