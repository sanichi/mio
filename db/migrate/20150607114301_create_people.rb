class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer  :born, limit: 2
      t.integer  :died, limit: 2
      t.string   :first_names, limit: Person::MAX_FN
      t.boolean  :gender
      t.string   :last_name, limit: Person::MAX_LN
      t.text     :notes

      t.timestamps null: false
    end
  end
end
