class CreateBidReviews < ActiveRecord::Migration
  def change
    create_table :bid_reviews do |t|
      t.boolean :starred
      t.boolean :read
      t.integer :officer_id
      t.integer :bid_id

      t.timestamps
    end
  end
end
