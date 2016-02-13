class AddNotesToTapas < ActiveRecord::Migration
  def change
    add_column :tapas, :notes, :text
  end
end
