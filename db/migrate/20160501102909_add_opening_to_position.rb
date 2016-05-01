class AddOpeningToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :opening_id, :integer, limit: 2
  end
end
