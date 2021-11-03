class RenameRegexpToJregexp < ActiveRecord::Migration[6.1]
  def change
    rename_column :grammars, :regexp, :jregexp
  end
end
