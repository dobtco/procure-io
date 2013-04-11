class AddRoleIdToOfficers < ActiveRecord::Migration
  def change
    add_column :officers, :role_id, :integer
    add_foreign_key "officers", "roles", :name => "officers_role_id_fk"
  end
end
