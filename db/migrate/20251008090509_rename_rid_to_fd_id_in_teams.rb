class RenameRidToFdIdInTeams < ActiveRecord::Migration[8.0]
  def change
    rename_column :teams, :rid, :fd_id
  end
end
