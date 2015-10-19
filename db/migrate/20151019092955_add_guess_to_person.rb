class AddGuessToPerson < ActiveRecord::Migration
  def change
    add_column :people, :born_guess, :boolean, default: false
    add_column :people, :died_guess, :boolean, default: false
  end
end
