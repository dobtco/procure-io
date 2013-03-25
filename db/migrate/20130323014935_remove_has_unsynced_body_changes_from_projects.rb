class RemoveHasUnsyncedBodyChangesFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :has_unsynced_body_changes
  end

  def down
    add_column :projects, :has_unsynced_body_changes, :boolean
  end
end
