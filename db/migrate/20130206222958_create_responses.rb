class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :responsable_id
      t.string :responsable_type
      t.integer :response_field_id
      t.text :value

      t.timestamps
    end

    add_foreign_key "responses", "response_fields", :name => "responses_response_field_id_fk"
  end
end
