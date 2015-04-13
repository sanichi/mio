class AdjustComments < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :comments do |t|
        dir.up do
          t.change :source, :string, limit: 50
          t.change :text, :text
        end

        dir.down do
          t.change :source, :string, limit: 30
          t.change :text, :string, limit: 140
        end
      end
    end
  end
end
