class AddTotalRatingsToBids < ActiveRecord::Migration
  def change
    add_column :bids, :total_ratings, :integer
  end
end
