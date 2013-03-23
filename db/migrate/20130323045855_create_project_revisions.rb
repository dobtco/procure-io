class CreateProjectRevisions < ActiveRecord::Migration
  def change
    create_table :project_revisions do |t|
      t.text :body
      t.integer :project_id
      t.integer :saved_by_officer_id

      t.timestamps
    end

    add_foreign_key "project_revisions", "projects", :name => "project_revisions_project_id_fk"
  end
end
