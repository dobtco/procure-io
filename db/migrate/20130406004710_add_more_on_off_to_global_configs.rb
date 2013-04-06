class AddMoreOnOffToGlobalConfigs < ActiveRecord::Migration
  def change
    add_column :global_configs, :watch_projects_enabled, :boolean, default: true
    add_column :global_configs, :save_searches_enabled, :boolean, default: true
    add_column :global_configs, :search_projects_enabled, :boolean, default: true
  end
end
