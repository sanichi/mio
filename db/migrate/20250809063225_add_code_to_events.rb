class AddCodeToEvents < ActiveRecord::Migration[8.0]
  def up
    add_column :mass_events, :code, :string, limit: 16
    change_column :mass_events, :name, :string, limit: 32

    MassEvent.all.each { |e| e.update_column(:code, e.name) }
  end

  def down
    remove_column :mass_events, :code
    change_column :mass_events, :name, :string, limit: 24
  end
end
