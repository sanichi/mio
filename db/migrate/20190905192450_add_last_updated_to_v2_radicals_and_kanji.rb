class AddLastUpdatedToV2RadicalsAndKanji < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_radicals, :last_updated, :date
    add_column :wk_kanjis, :last_updated, :date
  end
end
