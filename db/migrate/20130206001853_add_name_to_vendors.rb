class AddNameToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :name, :string
  end
end
