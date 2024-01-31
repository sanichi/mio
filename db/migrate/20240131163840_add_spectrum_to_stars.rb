class AddSpectrumToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :spectrum, :string, limit: Star::MAX_SPECTRUM
  end
end
