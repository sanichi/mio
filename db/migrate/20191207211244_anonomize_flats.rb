class AnonomizeFlats < ActiveRecord::Migration[6.0]
  def up
    remove_column :flats, :landlord_id
    remove_column :flats, :owner_id
    remove_column :flats, :tenant_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
