class RemoveSingletonGuardFromGlobalConfig < ActiveRecord::Migration
  def up
    remove_column :global_configs, :singleton_guard
  end

  def down
    add_column :global_configs, :singleton_guard, :integer
  end
end
