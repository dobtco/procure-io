class CreateBidReviews < ActiveRecord::Migration
  def change
    create_table :bid_reviews do |t|
      t.boolean :starred
      t.boolean :read
      t.integer :officer_id
      t.integer :bid_id

      t.timestamps
    end

    add_foreign_key "bid_reviews", "bids", :name => "bid_reviews_bid_id_fk"
    add_foreign_key "bid_reviews", "officers", :name => "bid_reviews_officer_id_fk"

  end
end
