class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :responsable_id
      t.string :responsable_type
      t.integer :response_field_id
      t.text :value
      t.string :sortable_value
      t.string :upload
      t.integer :user_id

      t.timestamps
    end
  end
end
