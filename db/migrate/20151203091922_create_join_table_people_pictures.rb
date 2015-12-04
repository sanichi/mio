class CreateJoinTablePeoplePictures < ActiveRecord::Migration
  def change
    create_join_table :people, :pictures do |t|
      t.index :person_id
      t.index :picture_id
    end

    reversible do |dir|
      dir.up do
        Picture.all.each do |p|
          execute <<-SQL
            INSERT INTO people_pictures VALUES (#{p.person_id}, #{p.id})
          SQL
        end
      end
    end
  end
end
