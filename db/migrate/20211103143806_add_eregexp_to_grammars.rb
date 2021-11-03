class AddEregexpToGrammars < ActiveRecord::Migration[6.1]
  def change
    add_column :grammars, :eregexp, :string, limit: 64
  end
end
