class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.references :home_team, foreign_key: { to_table: :teams }, null: false
      t.references :away_team, foreign_key: { to_table: :teams }, null: false
      t.integer    :home_score, :away_score, limit: 1
      t.integer    :season, limit: 2
      t.date       :date

      t.timestamps
    end
  end
end
