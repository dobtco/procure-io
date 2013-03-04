class ChangePostedToPostedAtOnProjects < ActiveRecord::Migration
  def change
    add_column :projects, :posted_at, :datetime
    add_column :projects, :posted_by_officer_id, :integer
    remove_column :projects, :posted
  end

  add_foreign_key "projects", "officers", :name => "projects_posted_by_officer_id_fk", :column => "posted_by_officer_id"
end
