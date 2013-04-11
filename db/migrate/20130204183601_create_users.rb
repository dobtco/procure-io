class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.text :notification_preferences
      t.integer :owner_id
      t.string :owner_type

      t.timestamps
    end
  end
end
