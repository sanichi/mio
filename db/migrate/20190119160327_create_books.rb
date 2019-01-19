class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string   :author, limit: Book::MAX_AUTHOR
      t.string   :category, limit: Book::MAX_CATEGORY
      t.string   :medium, limit: Book::MAX_MEDIUM
      t.text     :note
      t.string   :title, limit: Book::MAX_TITLE
      t.integer  :year, limit: 2

      t.timestamps null: false
    end
  end
end
