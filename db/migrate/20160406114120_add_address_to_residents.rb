class AddAddressToResidents < ActiveRecord::Migration
  def change
    add_column :residents, :address, :string, limit: Resident::MAX_ADDR
  end
end
