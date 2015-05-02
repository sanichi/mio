class AdjustFundNames < ActiveRecord::Migration
  def up
    Fund.all.each do |f|
      if f.name.match(/\A(.+) (Class|Platform) ([A-Z1-9]) \((Inc|Acc)\)\z/)
        f.update_column(:name, "#{$1} (#{$2} #{$3} #{$4})")
      end
    end
  end

  def down
    Fund.all.each do |f|
      if f.name.match(/\A(.+) \((Class|Platform) ([A-Z1-9]) (Inc|Acc)\)\z/)
        f.update_column(:name, "#{$1} #{$2} #{$3} (#{$4})")
      end
    end
  end
end
