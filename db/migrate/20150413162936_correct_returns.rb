class CorrectReturns < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :returns do |t|
        dir.up do
          t.change :year, :integer, limit: 2
        end

        dir.down do
          t.change :year, :integer, limit: 1
        end
      end
    end
  end
end
