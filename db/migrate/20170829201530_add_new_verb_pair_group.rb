class AddNewVerbPairGroup < ActiveRecord::Migration[5.1]
  def up
    VerbPair.where(group: 4).each { |vp| vp.update_column(:group, 5) }
    VerbPair.where(group: 3).each { |vp| vp.update_column(:group, 4) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
