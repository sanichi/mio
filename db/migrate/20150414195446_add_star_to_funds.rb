class AddStarToFunds < ActiveRecord::Migration
  def change
    add_column :funds, :star, :string, limit: 10
  end
end
