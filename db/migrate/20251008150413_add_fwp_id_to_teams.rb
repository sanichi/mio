class AddFwpIdToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :fwp_id, :integer
  end
end
