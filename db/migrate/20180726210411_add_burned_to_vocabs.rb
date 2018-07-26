class AddBurnedToVocabs < ActiveRecord::Migration[5.2]
  def change
    add_column :vocabs, :burned, :boolean, default: false
  end
end
