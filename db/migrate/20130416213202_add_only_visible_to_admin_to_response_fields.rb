class AddOnlyVisibleToAdminToResponseFields < ActiveRecord::Migration
  def change
    add_column :response_fields, :only_visible_to_admin, :boolean
  end
end
