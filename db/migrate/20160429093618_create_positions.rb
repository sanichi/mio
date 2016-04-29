class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string   :pieces, limit: 71
      t.string   :active, limit: 1
      t.string   :castling, limit: 4
      t.string   :en_passant, limit: 2
      t.integer  :half_move, limit: 2
      t.integer  :move, limit: 2
      t.string   :name, limit: Position::MAX_NAME
      t.text     :notes

      t.timestamps null: false
    end
  end
end
