class AddSizeToFunds < ActiveRecord::Migration
  def change
    add_column :funds, :size, :integer, limit: 3
  end
end
