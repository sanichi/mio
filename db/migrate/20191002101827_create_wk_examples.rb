class CreateWkExamples < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_examples do |t|
      t.string :japanese, limit: 100
      t.string :english, limit: 100

      t.timestamps
    end

    create_table :wk_examples_vocabs do |t|
      t.references :example, null: false
      t.references :vocab, null: false
    end
  end
end
