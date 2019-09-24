class MoveAudiosToReadings < ActiveRecord::Migration[6.0]
  def up
    add_column :wk_audios, :reading_id, :integer
    add_index  :wk_audios, :reading_id

    Wk::Vocab.all.to_a.each do |v|
      r = v.readings.first
      v.audios.each_with_index do |a, i|
        if i < 2
          a.update_column(:reading_id, r.id)
        else
          a.destroy
        end
      end
    end
  end

  def down
    remove_index :wk_audios, :reading_id
    remove_column :wk_audios, :reading_id
  end
end
