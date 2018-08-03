class AddRealmToPartnerships < ActiveRecord::Migration[5.2]
  def change
    add_column :partnerships, :realm, :integer, limit: 1, default: 0
  end
end
