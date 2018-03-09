class AddCategoryToSimilarKanjis < ActiveRecord::Migration[5.1]
  def up
    add_column :similar_kanjis, :category, :string, limit: SimilarKanji::MAX_CATEGORY
    SimilarKanji.update_all(category: "shape")
  end

  def down
    remove_column :similar_kanjis, :category
  end
end
