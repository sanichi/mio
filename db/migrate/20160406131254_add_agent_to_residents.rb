class AddAgentToResidents < ActiveRecord::Migration
  def change
    add_column :residents, :agent, :string, limit: Resident::MAX_AGNT
  end
end
