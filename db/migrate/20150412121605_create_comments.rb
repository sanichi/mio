class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.date       :date
      t.string     :source, limit: 30
      t.string     :text, limit: 140
      t.references :commentable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
