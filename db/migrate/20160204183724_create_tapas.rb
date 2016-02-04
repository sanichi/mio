class CreateTapas < ActiveRecord::Migration
  def change
    create_table :tapas do |t|
      t.string   :title, limit: Tapa::MAX_TITLE
      t.string   :keywords, limit: Tapa::MAX_KEYWORDS
      t.integer  :number, limit: 2

      t.timestamps null: false
    end
  end
end
