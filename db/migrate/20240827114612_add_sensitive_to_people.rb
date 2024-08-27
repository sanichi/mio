class AddSensitiveToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :sensitive, :text
  end
end
