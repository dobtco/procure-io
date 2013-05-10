class AddAwardMessageToBids < ActiveRecord::Migration
  def change
    add_column :bids, :award_message, :text
  end
end
