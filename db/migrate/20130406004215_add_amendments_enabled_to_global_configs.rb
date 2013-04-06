class AddAmendmentsEnabledToGlobalConfigs < ActiveRecord::Migration
  def change
    add_column :global_configs, :amendments_enabled, :boolean, default: true
  end
end
