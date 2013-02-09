class AddDismissedAtToBids < ActiveRecord::Migration
  def change
    add_column :bids, :dismissed_at, :datetime
    add_column :bids, :dismissed_by_officer_id, :integer
  end
end
