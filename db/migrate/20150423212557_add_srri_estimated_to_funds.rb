class AddSrriEstimatedToFunds < ActiveRecord::Migration
  def change
    add_column :funds, :srri_estimated, :boolean, default: false
  end
end
