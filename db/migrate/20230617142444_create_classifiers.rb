class CreateClassifiers < ActiveRecord::Migration[7.0]
  def change
    create_table :classifiers do |t|
      t.string   :category, limit: Classifier::MAX_CATEGORY
      t.string   :color, limit: Classifier::MAX_COLOR
      t.text     :description
      t.decimal  :max_amount, :min_amount, precision: 8, scale: 2
      t.string   :name, limit: Classifier::MAX_NAME

      t.timestamps
    end
  end
end
