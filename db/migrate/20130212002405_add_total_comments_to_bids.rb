class AddTotalCommentsToBids < ActiveRecord::Migration
  def change
    add_column :bids, :total_comments, :integer, null: false, default: 0
  end
end
