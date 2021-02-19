class CreatePlaces < ActiveRecord::Migration[6.1]
  def change
    create_table :places do |t|
      t.string   :ename, :jname, :reading, limit: 30
      t.string   :wiki, limit: 50
      t.string   :category, limit: 10
      t.integer  :pop, limit: 1

      t.references :region, foreign_key: { to_table: :places }

      t.timestamps
    end
  end
end
