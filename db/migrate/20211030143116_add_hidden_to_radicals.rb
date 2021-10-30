class AddHiddenToRadicals < ActiveRecord::Migration[6.1]
  def change
    add_column :wk_radicals, :hidden, :boolean, default: false
  end
end
