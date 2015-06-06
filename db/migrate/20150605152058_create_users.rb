class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, limit: User::MAX_EMAIL
      t.string :encrypted_password, limit: User::MAX_PASSWORD
      t.string :role, limit: User::MAX_ROLE

      t.timestamps null: false
    end
  end
end
