class AddRatingToBidReviews < ActiveRecord::Migration
  def change
    add_column :bid_reviews, :rating, :integer
  end
end
