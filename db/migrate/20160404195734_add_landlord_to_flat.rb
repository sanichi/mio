class AddLandlordToFlat < ActiveRecord::Migration
  def change
    add_column :flats, :landlord_id, :integer
  end
end
