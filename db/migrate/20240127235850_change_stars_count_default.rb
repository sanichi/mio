class ChangeStarsCountDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :constellations, :stars_count, from: nil, to: 0
  end
end
