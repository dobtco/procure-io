class AddDefaultToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :default, :boolean
  end
end
