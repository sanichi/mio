class AddMarriedNameToPerson < ActiveRecord::Migration
  def change
    add_column :people, :married_name, :string, limit: Person::MAX_LN
  end
end
