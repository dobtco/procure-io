class CreateAmendments < ActiveRecord::Migration
  def change
    create_table :amendments do |t|
      t.integer :project_id
      t.text :body
      t.datetime :posted_at
      t.integer :posted_by_officer_id

      t.timestamps
    end

    add_foreign_key "amendments", "officers", :name => "amendments_posted_by_officer_id_fk", :column => "posted_by_officer_id"
    add_foreign_key "amendments", "projects", :name => "amendments_project_id_fk"
  end
end
