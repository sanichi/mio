class AddGuessToPartnership < ActiveRecord::Migration
  def change
    add_column :partnerships, :wedding_guess, :boolean, default: false
    add_column :partnerships, :divorce_guess, :boolean, default: false
  end
end
