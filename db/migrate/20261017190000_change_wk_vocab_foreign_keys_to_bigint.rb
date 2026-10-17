class ChangeWkVocabForeignKeysToBigint < ActiveRecord::Migration[8.1]
  COLUMNS = { wk_readings: :vocab_id, wk_verb_pairs: [:transitive_id, :intransitive_id] }.freeze

  def up
    each_column { |table, column| change_column table, column, :bigint }
  end

  def down
    each_column { |table, column| change_column table, column, :integer }
  end

  private

  def each_column
    COLUMNS.each { |table, columns| Array(columns).each { |column| yield table, column } }
  end
end
