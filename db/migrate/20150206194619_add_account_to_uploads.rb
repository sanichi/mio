class AddAccountToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :account, :string, limit: 3
  end
end
