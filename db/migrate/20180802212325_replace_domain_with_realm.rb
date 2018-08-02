class ReplaceDomainWithRealm < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :realm, :integer, limit: 1, default: 0
    remove_column :people, :domain, :integer, limit: 1, default: 0
  end
end
