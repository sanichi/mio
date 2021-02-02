class AddDivisionToTeams < ActiveRecord::Migration[6.1]
  def up
    add_column :teams, :division, :integer, limit: 1, default: 1

    Team.all.each do |t|
      p.update_column(:division, 1)
    end
  end

  def down
    remove_column :teams, :division, :integer
  end
end
