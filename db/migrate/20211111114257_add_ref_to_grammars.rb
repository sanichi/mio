class AddRefToGrammars < ActiveRecord::Migration[6.1]
  def change
    add_column :grammars, :ref, :string, limit: 10
  end
end
