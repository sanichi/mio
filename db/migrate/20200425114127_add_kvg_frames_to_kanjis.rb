class AddKvgFramesToKanjis < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_kanjis, :kvg_frames, :text
  end
end
