class MakeAudiosPolymorphic < ActiveRecord::Migration[7.0]
  def up
    add_column :wk_audios, :audible_id, :integer
    add_column :wk_audios, :audible_type, :string

    Wk::Audio.all.each do |a|
      a.update_column(:audible_id, a.reading_id)
      a.update_column(:audible_type, "Wk::Reading")
    end
  end

  def down
    remove_column :wk_audios, :audible_id
    remove_column :wk_audios, :audible_type
  end
end
