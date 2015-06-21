class ChangeMarriagesToPartnerships < ActiveRecord::Migration
  def change
    rename_table :marriages, :partnerships
  end
end
