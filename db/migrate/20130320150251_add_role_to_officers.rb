class AddRoleToOfficers < ActiveRecord::Migration
  def change
    add_column :officers, :role, :integer, default: 1
  end
end
