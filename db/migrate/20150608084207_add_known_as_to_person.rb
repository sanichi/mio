class AddKnownAsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :known_as, :string, limit: Person::MAX_KA
  end
end
