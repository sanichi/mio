class AddHiddenToVocabs < ActiveRecord::Migration[6.1]
  def change
    add_column :wk_vocabs, :hidden, :boolean, default: false
  end
end
