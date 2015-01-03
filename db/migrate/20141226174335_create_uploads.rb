class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.text     :content
      t.string   :content_type
      t.string   :error
      t.string   :name
      t.integer  :size
      t.datetime :created_at
    end
  end
end
