class CreateLogins < ActiveRecord::Migration
  def change
    create_table :logins do |t|
      t.string   :email, limit: User::MAX_EMAIL
      t.string   :ip, limit: Login::MAX_IP
      t.boolean  :success
      t.datetime :created_at
    end
  end
end
