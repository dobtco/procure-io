class AddPostedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :posted, :boolean
  end
end
