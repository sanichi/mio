class CreateBlog < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.text       :story
      t.string     :title, limit: Blog::MAX_TITLE
      t.integer    :user_id

      t.timestamps null: false
    end
  end
end
