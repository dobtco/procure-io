class CreateFormTemplates < ActiveRecord::Migration
  def change
    create_table :form_templates do |t|
      t.string :name
      t.integer :organization_id
      t.text :form_options

      t.timestamps
    end
  end
end
