class AddRapidIdToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :rid, :integer
  end
end
