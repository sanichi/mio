class AddAudioToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :audio, :string, limit: Question::MAX_AUDIO
  end
end
