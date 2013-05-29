class CreateBidReviews < ActiveRecord::Migration
  def change
    create_table :bid_reviews do |t|
      t.boolean :starred
      t.boolean :read
      t.integer :user_id
      t.integer :bid_id
      t.integer :rating

      t.timestamps
    end
  end
end
