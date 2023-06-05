class AddAccentToKanas < ActiveRecord::Migration[7.0]
  def change
    add_column :wk_kanas, :accent_position, :integer, limit: 1
    add_column :wk_kanas, :accent_pattern, :integer, limit: 1
  end
end
