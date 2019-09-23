class AddSeriesNoNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :series, :string, limit: Note::MAX_SERIES
    add_column :notes, :number, :integer, limit: 1
  end
end
