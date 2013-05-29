class CreateVendorTeamMembers < ActiveRecord::Migration
  def change
    create_table :vendor_team_members do |t|
      t.integer :vendor_id
      t.integer :user_id
      t.boolean :owner, default: false

      t.timestamps
    end
  end
end
