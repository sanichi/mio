class CreateResidents < ActiveRecord::Migration
  def change
    create_table :residents do |t|
      t.integer  :bay, limit: 1, default: 0
      t.integer  :block, limit: 1
      t.integer  :flat, limit: 1
      t.string   :first_names, limit: Person::MAX_FN
      t.string   :last_name, limit: Person::MAX_LN
      t.string   :email, limit: User::MAX_EMAIL

      t.timestamps null: false
    end
  end
end
