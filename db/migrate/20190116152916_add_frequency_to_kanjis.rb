class AddFrequencyToKanjis < ActiveRecord::Migration[5.2]
  def change
    add_column :kanjis, :frequency, :integer, limit: 2, default: 0
  end
end
