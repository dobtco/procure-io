class ChangePostedToPostedAtOnProjects < ActiveRecord::Migration
  def change
    add_column :projects, :posted_at, :datetime
    add_column :projects, :posted_by_officer_id, :integer
    remove_column :projects, :posted
  end
end
