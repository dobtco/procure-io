class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.integer :project_id
      t.integer :officer_id
      t.boolean :owner

      t.timestamps
    end

    add_foreign_key "collaborators", "officers", :name => "collaborators_officer_id_fk"
    add_foreign_key "collaborators", "projects", :name => "collaborators_project_id_fk"
  end
end
