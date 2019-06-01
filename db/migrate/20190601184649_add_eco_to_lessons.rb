class AddEcoToLessons < ActiveRecord::Migration[5.2]
  def change
    add_column :lessons, :eco, :string, limit: Lesson::MAX_ECO
  end
end
