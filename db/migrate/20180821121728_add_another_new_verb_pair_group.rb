class AddAnotherNewVerbPairGroup < ActiveRecord::Migration[5.2]
  def up
    # 6 (irregular) goes to 7 to make way for a new 6
    VerbPair.where(group: 6).each { |vp| vp.update_column(:group, 7) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
