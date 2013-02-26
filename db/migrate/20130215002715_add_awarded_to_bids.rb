class AddAwardedToBids < ActiveRecord::Migration
  def change
    add_column :bids, :awarded_at, :datetime
    add_column :bids, :awarded_by_officer_id, :integer
  end
end
