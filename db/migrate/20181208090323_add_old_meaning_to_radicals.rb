class AddOldMeaningToRadicals < ActiveRecord::Migration[5.2]
  def change
    add_column :radicals, :old_meaning, :string, limit: Radical::MAX_MEANING
  end
end
