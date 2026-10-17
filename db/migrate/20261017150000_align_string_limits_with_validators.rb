class AlignStringLimitsWithValidators < ActiveRecord::Migration[8.1]
  LIMITS = {
    grammar_groups: { title: [200, 256] },
    places:         { vbox: [17, 20], mark_position: [9, 10], text_position: [9, 10] },
    subscriptions:  { payee: [50, nil], source: [40, nil] }
  }.freeze

  def up
    LIMITS.each do |table, columns|
      columns.each { |column, (new_limit, _)| change_column table, column, :string, limit: new_limit }
    end
  end

  def down
    LIMITS.each do |table, columns|
      columns.each { |column, (_, old_limit)| change_column table, column, :string, limit: old_limit }
    end
  end
end
