class AddLengthToSounds < ActiveRecord::Migration[6.1]
  def up
    add_column :sounds, :length, :integer, limit: 2

    Sound.all.each do |s|
      s.length = (`wc -c #{s.file}`.to_i * 40.8 / 1000000.0).round
      s.save!
    end
  end

  def down
    remove_column :sounds, :length
  end
end
