class AddTitleToPictures < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :pictures do |t|
        dir.up do
          t.string :title
          Picture.all.each { |p| p.update_column(:title, p.send(:calculate_title)) }
        end

        dir.down do
          t.remove :title
        end
      end
    end
  end
end
