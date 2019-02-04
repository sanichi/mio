class AddBorrowerToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :borrower, :string, limit: Book::MAX_BORROWER
  end
end
