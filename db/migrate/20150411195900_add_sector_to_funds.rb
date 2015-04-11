class AddSectorToFunds < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :funds do |t|
        dir.up do
          t.change :annual_fee, :decimal, precision: 3, scale: 2
          t.string :sector, limit: 40
        end

        dir.down do
          t.change :annual_fee, :decimal, precision: 2, scale: 1
          t.remove :sector
        end
      end
    end
  end
end
