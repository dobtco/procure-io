class CreateProjectsTagsTable < ActiveRecord::Migration
  def change
    create_table :projects_tags, id: false do |t|
      t.integer :project_id
      t.integer :tag_id
    end

    add_foreign_key "projects_tags", "projects", :name => "projects_tags_project_id_fk"
    add_foreign_key "projects_tags", "tags", :name => "projects_tags_tag_id_fk"
  end
end
