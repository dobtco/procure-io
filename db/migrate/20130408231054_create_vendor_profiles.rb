class CreateVendorProfiles < ActiveRecord::Migration
  def change
    create_table :vendor_profiles do |t|
      t.integer :vendor_id

      t.timestamps
    end
  end
end
