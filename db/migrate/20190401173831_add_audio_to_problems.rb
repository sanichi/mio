class AddAudioToProblems < ActiveRecord::Migration[5.2]
  def change
    add_column :problems, :audio, :string, limit: Problem::MAX_AUDIO
  end
end
