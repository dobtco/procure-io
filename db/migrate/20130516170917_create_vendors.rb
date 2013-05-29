class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :slug
      t.string :email

      # Profile info
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps
    end

    add_index :vendors, :slug, unique: true
  end
end
