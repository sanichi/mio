class CreateRadicalKanjiJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :kanjis, :radicals, table_name: "wk_kanjis_radicals" do |t|
      t.index :radical_id
      t.index :kanji_id
    end
  end
end
