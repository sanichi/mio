class AddOrderToSounds < ActiveRecord::Migration[6.1]
  def up
    add_column :sounds, :ordinal, :integer, limit: 2

    Sound.all.map do |s|
      [s, s.category] + s.name.split(/(\d+)/).map{|n| n.match?(/\A\d+\z/) ? n.to_i : n}
    end.sort do |a,b|
      p = a[1..-1]
      q = b[1..-1]
      p <=> q
    end.each_with_index do |a, i|
      s = a[0]
      s.ordinal = i + 1
      s.save!
    end
  end

  def down
    remove_column :sounds, :ordinal
  end
end
