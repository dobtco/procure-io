class AddAccountDisabledToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :account_disabled, :boolean, default: false
  end
end
