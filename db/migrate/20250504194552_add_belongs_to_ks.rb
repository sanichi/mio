class AddBelongsToKs < ActiveRecord::Migration[8.0]
  def change
    add_belongs_to :ks_boots, :ks_journal, null: false
    add_belongs_to :ks_mems, :ks_journal, null: false
    add_belongs_to :ks_tops, :ks_journal, null: false

    add_column :ks_journals, :boots_count, :integer, default: 0, null: false
    add_column :ks_journals, :mems_count, :integer, default: 0, null: false
    add_column :ks_journals, :tops_count, :integer, default: 0, null: false
    add_column :ks_journals, :procs_count, :integer, default: 0, null: false
    add_column :ks_tops, :procs_count, :integer, default: 0, null: false

    remove_column :ks_journals, :boot, :integer
    remove_column :ks_journals, :mem, :integer
    remove_column :ks_journals, :top, :integer
    remove_column :ks_journals, :proc, :integer
  end
end
