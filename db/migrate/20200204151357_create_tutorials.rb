class CreateTutorials < ActiveRecord::Migration[6.0]
  def change
    create_table :tutorials do |t|
      t.date   :date
      t.string :summary, limit: Tutorial::MAX_SUMMARY

      t.timestamps
    end
  end
end
