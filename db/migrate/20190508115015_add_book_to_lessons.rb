class AddBookToLessons < ActiveRecord::Migration[5.2]
  def change
    add_column :lessons, :book, :string, limit: Lesson::MAX_BOOK
  end
end
