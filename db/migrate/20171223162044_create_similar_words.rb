class CreateSimilarWords < ActiveRecord::Migration[5.1]
  def change
    create_table :similar_words do |t|
      t.string :readings, limit: SimilarWord::MAX_READINGS
      t.timestamps null: false
    end
  end
end
