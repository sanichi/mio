class AddNoteToWkVocabs < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_vocabs, :notes, :text
  end
end
