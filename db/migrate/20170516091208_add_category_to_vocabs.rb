class AddCategoryToVocabs < ActiveRecord::Migration[5.1]
  def change
    add_column :vocabs, :category, :string, limit: Vocab::MAX_CATEGORY
  end
end
