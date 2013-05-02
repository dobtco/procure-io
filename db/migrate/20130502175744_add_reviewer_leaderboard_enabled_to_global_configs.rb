class AddReviewerLeaderboardEnabledToGlobalConfigs < ActiveRecord::Migration
  def change
    add_column :global_configs, :reviewer_leaderboard_enabled, :boolean, default: false
  end
end
