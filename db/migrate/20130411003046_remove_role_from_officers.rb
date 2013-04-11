class RemoveRoleFromOfficers < ActiveRecord::Migration
  def up
    remove_column :officers, :role
  end

  def down
    add_column :officers, :role, :integer
  end
end
