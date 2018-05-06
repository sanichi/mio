class AddSecondNewVerbPairGroup < ActiveRecord::Migration[5.2]
  def up
    VerbPair.where(group: 5).each { |vp| vp.update_column(:group, 6) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
