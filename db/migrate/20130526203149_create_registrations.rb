class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :name
      t.integer :organization_id
      t.integer :registration_type
      t.text :form_options
      t.boolean :vendor_can_update_status, default: false
      t.datetime :posted_at
      t.integer :poster_id

      t.timestamps
    end
  end
end
