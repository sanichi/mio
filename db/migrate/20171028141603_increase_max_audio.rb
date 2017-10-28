class IncreaseMaxAudio < ActiveRecord::Migration[5.1]
  def up
    change_column :vocabs, :audio, :string, :limit => 75
  end

  def down
    change_column :vocabs, :audio, :string, :limit => 50
  end
end
