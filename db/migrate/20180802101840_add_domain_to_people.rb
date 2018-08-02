class AddDomainToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :domain, :integer, limit: 1, default: 0
  end
end
