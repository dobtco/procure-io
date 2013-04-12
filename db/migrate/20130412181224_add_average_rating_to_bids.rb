class AddAverageRatingToBids < ActiveRecord::Migration
  def change
    add_column :bids, :average_rating, :decimal, precision: 3, scale: 2
  end
end
