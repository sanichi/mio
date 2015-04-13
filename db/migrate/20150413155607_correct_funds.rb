class CorrectFunds < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :funds do |t|
        dir.up do
          t.change :company, :string, limit: 50
          t.change :name, :string, limit: 70
        end

        dir.down do
          t.change :company, :string, limit: 70
          t.change :name, :string, limit: 50
        end
      end
    end
  end
end
