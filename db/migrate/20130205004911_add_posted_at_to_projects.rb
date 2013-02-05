class AddPostedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :posted_at, :datetime
  end
end
