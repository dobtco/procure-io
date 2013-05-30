class AddProfileInfoToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :phone_number, :string
    add_column :vendors, :contact_name, :string
  end
end
