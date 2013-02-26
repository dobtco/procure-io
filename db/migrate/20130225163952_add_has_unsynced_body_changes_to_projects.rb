class AddHasUnsyncedBodyChangesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :has_unsynced_body_changes, :boolean
  end
end
