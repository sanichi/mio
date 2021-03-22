class AddLastToTests < ActiveRecord::Migration[6.1]
  def change
    add_column :tests, :last, :string, limit: 10
  end
end
