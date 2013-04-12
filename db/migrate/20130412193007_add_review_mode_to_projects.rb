class AddReviewModeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :review_mode, :integer, default: 1
  end
end
