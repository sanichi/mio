class AddLongToMisas < ActiveRecord::Migration[5.1]
  def change
    add_column :misas, :long, :string, limit: Misa::MAX_LONG
  end
end
