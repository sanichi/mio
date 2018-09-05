class CreateDragons < ActiveRecord::Migration[5.2]
  def change
    create_table :dragons do |t|
      t.boolean  :male, default: true
      t.string   :first_name, limit: Dragon::MAX_FIRST_NAME
      t.string   :last_name, limit: Dragon::MAX_LAST_NAME
    end
  end
end
