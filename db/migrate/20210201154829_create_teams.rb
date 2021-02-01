class CreateTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :teams do |t|
      t.string :name, limit: Team::MAX_NAME
      t.string :slug, limit: Team::MAX_NAME
      t.string :short, limit: Team::MAX_SHORT

      t.timestamps
    end
  end
end
