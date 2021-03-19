class InitTests < ActiveRecord::Migration[6.1]
  def up
    [Wk::Example, Place, Border].each do |m|
      m.pluck(:id).each { |i| Test.create!(testable_type: m, testable_id: i) }
    end
  end

  def down
    Test.delete_all
  end
end
