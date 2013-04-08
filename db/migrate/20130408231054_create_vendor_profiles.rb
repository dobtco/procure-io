class CreateVendorProfiles < ActiveRecord::Migration
  def change
    create_table :vendor_profiles do |t|
      t.integer :vendor_id

      t.timestamps
    end

    add_foreign_key "vendor_profiles", "vendors", :name => "vendor_profiles_vendor_id_fk"
  end
end
