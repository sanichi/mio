class LengthenExpensesDescription < ActiveRecord::Migration
  def change
    change_column :expenses, :description, :string, limit: 60
  end
end
