class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.text    :content
      t.string  :content_type
      t.string  :error
      t.string  :name
      t.boolean :parsed, default: false
      t.integer :size

      t.timestamps null: false
    end
  end
end
