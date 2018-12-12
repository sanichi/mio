class CreateLessons < ActiveRecord::Migration[5.2]
  def change
    create_table :lessons do |t|
      t.string   :chapter, limit: Lesson::MAX_CHAPTER
      t.integer  :chapter_no, limit: 1
      t.integer  :complete, limit: 1, default: 0
      t.string   :link, limit: Lesson::MAX_LINK
      t.text     :note
      t.string   :section, limit: Lesson::MAX_SECTION
      t.string   :series, limit: Lesson::MAX_SERIES

      t.timestamps null: false
    end
  end
end
