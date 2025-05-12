class CreateKsPcpus < ActiveRecord::Migration[8.0]
  def change
    create_table :ks_pcpus do |t|
      t.integer  :pid
      t.decimal  :pcpu, precision: 4, scale: 1
      t.string   :command, limit: 100
      t.string   :short, limit: 32

      t.belongs_to :ks_cpu, null: false
    end

    add_column :ks_journals, :pcpus_count, :integer, default: 0, null: false
  end
end
