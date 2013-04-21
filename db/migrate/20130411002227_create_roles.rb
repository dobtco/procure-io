class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.integer :role_type
      t.text :permissions

      t.timestamps
    end
  end
end
