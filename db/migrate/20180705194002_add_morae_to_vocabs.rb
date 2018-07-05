class AddMoraeToVocabs < ActiveRecord::Migration[5.2]
  def up
    add_column :vocabs, :morae, :integer, default: 0, limit: 1
    Vocab.find_each { |v| v.update_column(:morae, Vocab.count_morae(v.reading)) }
  end

  def down
    remove_column :vocabs, :morae
  end
end
