class AddAccentToVocabs < ActiveRecord::Migration[5.2]
  def change
    add_column :vocabs, :accent, :integer, limit: 1
  end
end
