class RenameGenderToMale < ActiveRecord::Migration
  def change
    rename_column :people, :gender, :male
  end
end
