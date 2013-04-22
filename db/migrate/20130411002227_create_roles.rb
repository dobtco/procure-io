class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.integer :role_type, null: false, default: 1
      t.text :permissions

      t.timestamps
    end
  end
end
