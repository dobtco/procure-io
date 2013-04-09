class AddFormOptionsToFormTemplates < ActiveRecord::Migration
  def change
    add_column :form_templates, :form_options, :text
  end
end
