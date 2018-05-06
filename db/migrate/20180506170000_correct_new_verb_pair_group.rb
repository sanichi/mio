class CorrectNewVerbPairGroup < ActiveRecord::Migration[5.2]
  def up
    # 9 acts as a temporary value for swapping since max current value is 6
    VerbPair.where(group: 4).each { |vp| vp.update_column(:group, 9) }
    VerbPair.where(group: 5).each { |vp| vp.update_column(:group, 4) }
    VerbPair.where(group: 9).each { |vp| vp.update_column(:group, 5) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
