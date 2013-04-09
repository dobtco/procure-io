class AddFormOptionsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :form_options, :text
  end
end
