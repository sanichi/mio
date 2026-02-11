class AddRecordsMatchedToPpSyncLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :pp_sync_logs, :records_matched, :integer, default: 0, null: false
  end
end
