class CreateWkAudios < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_audios do |t|
      t.string   :file, limit: Wk::Audio::MAX_FILE
      t.integer  :wk_id
      t.integer  :vocab_id
    end

    add_index :wk_audios, :vocab_id
  end
end
