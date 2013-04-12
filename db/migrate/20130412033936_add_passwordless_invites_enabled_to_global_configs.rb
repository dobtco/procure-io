class AddPasswordlessInvitesEnabledToGlobalConfigs < ActiveRecord::Migration
  def change
    add_column :global_configs, :passwordless_invites_enabled, :boolean, default: false
  end
end
