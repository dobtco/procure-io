class AddFeaturedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :featured, :boolean
  end
end
