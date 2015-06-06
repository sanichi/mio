class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, limit: 75
      t.string :encrypted_password, limit: 32
      t.string :role, limit: 20

      t.timestamps null: false
    end
  end
end
