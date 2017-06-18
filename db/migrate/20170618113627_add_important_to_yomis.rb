class AddImportantToYomis < ActiveRecord::Migration[5.1]
  def change
    change_table :yomis do |t|
      t.boolean  :important, default: true
    end
  end
end
