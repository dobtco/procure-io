class CreateResponseFields < ActiveRecord::Migration
  def change
    create_table :response_fields do |t|
      t.integer :project_id
      t.string :label
      t.string :field_type
      t.text :field_options

      t.timestamps
    end
  end
end
