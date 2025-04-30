class CreateKsProcs < ActiveRecord::Migration[8.0]
  def change
    create_table :ks_procs do |t|
      t.integer  :pid, :mem
      t.string   :command, limit: 100
      t.string   :short, limit: 32

      t.belongs_to :ks_top, null: false
    end
  end
end
