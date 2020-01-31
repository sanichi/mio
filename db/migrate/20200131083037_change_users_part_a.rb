class ChangeUsersPartA < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :first_name, :string, limit: User::MAX_FN
    add_column :users, :last_name, :string, limit: User::MAX_LN

    User.all.each do |u|
      u.update_columns(first_name: "Unknown", last_name: "Unknown")
    end
  end
end
