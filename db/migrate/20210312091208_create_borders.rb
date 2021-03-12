class CreateBorders < ActiveRecord::Migration[6.1]
  def change
    create_table :borders do |t|
      t.belongs_to :from, foreign_key: { to_table: :places }
      t.belongs_to :to, foreign_key: { to_table: :places }
      t.string :direction, limit: 10

      t.timestamps
    end
  end
end
