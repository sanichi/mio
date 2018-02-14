class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.text       :stuff
      t.string     :title, limit: Note::MAX_TITLE

      t.timestamps null: false
    end
  end
end
