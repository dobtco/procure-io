class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :vendor_id
      t.integer :project_id
      t.datetime :submitted_at
      t.datetime :dismissed_at
      t.integer :dismisser_id
      t.integer :total_stars, default: 0
      t.integer :total_comments, default: 0
      t.datetime :awarded_at
      t.integer :awarder_id
      t.decimal :average_rating, precision: 3, scale: 2
      t.integer :total_ratings, default: 0
      t.string :bidder_name
      t.text :dismissal_message
      t.boolean :show_dismissal_message_to_vendor, default: false
      t.text :award_message

      t.timestamps
    end
  end
end
