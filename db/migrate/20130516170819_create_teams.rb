class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :organization_id
      t.integer :permission_level, default: 1
      t.integer :user_count, default: 0

      t.timestamps
    end
  end
end
