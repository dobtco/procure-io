class CreateOrganizationTeamMembers < ActiveRecord::Migration
  def change
    create_table :organization_team_members do |t|
      t.integer :team_id
      t.integer :user_id
      t.integer :added_by_user_id

      t.timestamps
    end
  end
end
