class AddDayToExamples < ActiveRecord::Migration[8.0]
  def change
    add_column :wk_examples, :day, :date
  end
end
