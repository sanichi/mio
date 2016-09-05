class AddOpening365ToPosition < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :opening_365, :string, limit: Position::MAX_OPENING_365
  end
end
