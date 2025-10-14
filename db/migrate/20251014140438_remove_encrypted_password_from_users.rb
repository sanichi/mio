class RemoveEncryptedPasswordFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :encrypted_password, :string
  end
end
