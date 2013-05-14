class RemoveResponseFieldsFromFormTemplates < ActiveRecord::Migration
  def up
    remove_column :form_templates, :response_fields
  end

  def down
    add_column :form_templates, :response_fields, :text
  end
end
