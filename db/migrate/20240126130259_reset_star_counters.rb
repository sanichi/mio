class ResetStarCounters < ActiveRecord::Migration[7.1]
  def up
    Constellation.all.each do |c|
      Constellation.reset_counters(c.id, :stars)
    end
  end

  def down
    # no rollback needed
  end
end
