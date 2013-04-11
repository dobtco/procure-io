class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.boolean :account_disabled
      t.string :company_name

      t.timestamps
    end
  end
end
