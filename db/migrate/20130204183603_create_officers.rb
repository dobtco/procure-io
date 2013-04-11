class CreateOfficers < ActiveRecord::Migration
  def change
    create_table :officers do |t|
      t.integer :role_id
      t.string :title
      t.string :name

      t.timestamps
    end
  end
end
