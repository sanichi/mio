class DropKanshiTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :ks_boots
    drop_table :ks_cpus
    drop_table :ks_journals
    drop_table :ks_mems
    drop_table :ks_pcpus
    drop_table :ks_procs
    drop_table :ks_tops
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
