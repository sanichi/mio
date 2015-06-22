class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string     :url, limit: Link::MAX_URL
      t.string     :target, limit: Link::MAX_TARGET, default: "external"
      t.string     :text, limit: Link::MAX_TEXT
      t.references :linkable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
