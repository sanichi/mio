class DropPatternFromVocabs < ActiveRecord::Migration[5.2]
  def change
    remove_column :vocabs, :pattern, :string, limit: 10
  end
end
