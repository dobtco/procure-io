class CreateVendorRegistrations < ActiveRecord::Migration
  def change
    create_table :vendor_registrations do |t|
      t.integer :registration_id
      t.integer :vendor_id
      t.integer :status, default: 1
      t.text :notes
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
