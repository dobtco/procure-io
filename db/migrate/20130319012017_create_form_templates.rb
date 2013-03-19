class CreateFormTemplates < ActiveRecord::Migration
  def change
    create_table :form_templates do |t|
      t.string :name
      t.text :response_fields

      t.timestamps
    end
  end
end
