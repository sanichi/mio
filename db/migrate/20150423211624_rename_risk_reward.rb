class RenameRiskReward < ActiveRecord::Migration
  def change
    rename_column :funds, :risk_reward_profile, :srri
  end
end
