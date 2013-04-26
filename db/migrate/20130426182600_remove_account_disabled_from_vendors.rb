class RemoveAccountDisabledFromVendors < ActiveRecord::Migration
  def up
    remove_column :vendors, :account_disabled
  end

  def down
    add_column :vendors, :account_disabled, :string
  end
end
