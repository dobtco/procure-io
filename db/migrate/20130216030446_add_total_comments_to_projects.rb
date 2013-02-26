class AddTotalCommentsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :total_comments, :integer, null: false, default: 0
  end
end
