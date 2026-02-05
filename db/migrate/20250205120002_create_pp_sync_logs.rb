class CreatePpSyncLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :pp_sync_logs do |t|
      t.string   :query_type,       limit: 25, null: false
      t.integer  :records_scanned,  default: 0, null: false
      t.integer  :records_created,   default: 0, null: false
      t.integer  :records_updated,   default: 0, null: false
      t.integer  :records_unchanged, default: 0, null: false
      t.text     :error_message
      t.datetime :started_at,       null: false
      t.decimal  :duration_seconds, precision: 8, scale: 2
    end

    add_index :pp_sync_logs, [:query_type, :started_at]
  end
end
