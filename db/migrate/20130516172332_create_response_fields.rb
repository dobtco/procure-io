class CreateResponseFields < ActiveRecord::Migration
  def change
    create_table :response_fields do |t|
      t.string :key
      t.integer :response_fieldable_id
      t.string :response_fieldable_type
      t.text :label
      t.string :field_type
      t.text :field_options
      t.integer :sort_order
      t.boolean :only_visible_to_admin

      t.timestamps
    end
  end
end
