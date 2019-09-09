class AddAccentToWkVocabs < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_vocabs, :accent_position, :integer, limit: 1
    add_column :wk_vocabs, :accent_pattern, :integer, limit: 1
  end
end
