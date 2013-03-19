class AddFormDescriptionAndConfirmationMessageToFormTemplates < ActiveRecord::Migration
  def change
    add_column :form_templates, :form_description, :text
    add_column :form_templates, :form_confirmation_message, :text
  end
end
