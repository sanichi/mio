class AddJointToIncomes < ActiveRecord::Migration
  def change
    add_column :incomes, :joint, :integer, limit: 1, default: 100
  end
end
