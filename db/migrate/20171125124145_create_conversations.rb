class CreateConversations < ActiveRecord::Migration[5.1]
  def change
    create_table :conversations do |t|
      t.string   :audio, limit: Conversation::MAX_AUDIO
      t.text     :story
      t.string   :title, limit: Conversation::MAX_TITLE

      t.timestamps null: false
    end
  end
end
