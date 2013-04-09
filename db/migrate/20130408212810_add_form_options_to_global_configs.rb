class AddFormOptionsToGlobalConfigs < ActiveRecord::Migration
  def change
    add_column :global_configs, :form_options, :text
  end
end
