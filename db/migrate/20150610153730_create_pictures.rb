class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.attachment :image
      t.text       :description
      t.integer    :person_id

      t.timestamps null: false
    end
  end
end
