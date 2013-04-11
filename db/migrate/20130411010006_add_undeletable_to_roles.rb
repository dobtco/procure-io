class AddUndeletableToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :undeletable, :boolean
  end
end
