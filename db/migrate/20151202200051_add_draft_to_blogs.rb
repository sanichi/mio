class AddDraftToBlogs < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :blogs do |t|
        dir.up do
          t.boolean :draft, default: true
          Blog.all.each { |b| b.update_column(:draft, false) }
        end

        dir.down do
          t.remove :draft
        end
      end
    end
  end
end
