class CreateKsCpus < ActiveRecord::Migration[8.0]
  def change
    create_table :ks_cpus do |t|
      t.string   :server, limit: 3
      t.datetime :measured_at
      t.integer  :pcpus_count, default: 0, null: false

      t.belongs_to :ks_journal, null: false
    end

    add_index :ks_cpus, [:measured_at, :server], unique: true

    add_column :ks_journals, :cpus_count, :integer, default: 0, null: false
  end
end
