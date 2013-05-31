class CreateProjectAttachments < ActiveRecord::Migration
  def change
    create_table :project_attachments do |t|
      t.integer :project_id
      t.string :upload

      t.timestamps
    end

    add_foreign_key "project_attachments", "projects", :name => "project_attachments_project_id_fk"
  end
end
