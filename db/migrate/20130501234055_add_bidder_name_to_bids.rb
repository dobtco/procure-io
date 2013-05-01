class AddBidderNameToBids < ActiveRecord::Migration
  def change
    add_column :bids, :bidder_name, :string
  end
end
