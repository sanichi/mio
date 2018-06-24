class AddPatternToVocabs < ActiveRecord::Migration[5.2]
  def change
    add_column :vocabs, :pattern, :string, limit: 10
  end
end
