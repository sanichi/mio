class AddLastNotedToWkVocabs < ActiveRecord::Migration[6.0]
  def up
    add_column :wk_vocabs, :last_noted, :datetime

    now = Time.now
    ago = now.days_ago(1)

    Wk::Vocab.all.each { |v| v.update_column(:last_noted, v.notes.present? ? now : ago) }
  end

  def down
    remove_column :wk_vocabs, :last_noted
  end
end
