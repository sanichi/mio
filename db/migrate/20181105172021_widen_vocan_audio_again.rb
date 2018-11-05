class WidenVocanAudioAgain < ActiveRecord::Migration[5.2]
  def up
    change_column :vocabs, :audio, :string, :limit => 100
  end

  def down
    change_column :vocabs, :audio, :string, :limit => 75
  end
end
