class AddNotesToTutorials < ActiveRecord::Migration[6.0]
  def change
    add_column :tutorials, :notes, :text
  end
end
