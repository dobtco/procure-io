class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :responsable_id
      t.string :responsable_type
      t.integer :response_field_id
      t.text :value

      t.timestamps
    end
  end
end
