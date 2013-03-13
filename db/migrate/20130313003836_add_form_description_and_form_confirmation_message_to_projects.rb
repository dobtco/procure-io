class AddFormDescriptionAndFormConfirmationMessageToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :form_description, :text
    add_column :projects, :form_confirmation_message, :text
  end
end
