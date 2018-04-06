class AddPublishedToMisas < ActiveRecord::Migration[5.1]
  def change
    add_column :misas, :published, :date
  end
end
