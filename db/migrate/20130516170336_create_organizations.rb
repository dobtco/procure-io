class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :email
      t.string :username
      t.string :logo
      t.text :event_hooks

      t.timestamps
    end

    add_index :organizations, :username, unique: true
  end
end
