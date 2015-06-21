class AddMarriageToPartnership < ActiveRecord::Migration
  def change
    add_column :partnerships, :marriage, :boolean, default: true
  end
end
