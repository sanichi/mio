class AddKvgToWkKanjis < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_kanjis, :kvg_id, :string, length: 5
    add_column :wk_kanjis, :kvg_xml, :text
  end
end
