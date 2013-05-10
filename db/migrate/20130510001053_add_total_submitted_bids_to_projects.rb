class AddTotalSubmittedBidsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :total_submitted_bids, :integer, default: 0
  end
end
