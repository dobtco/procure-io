class AddSubmittedAtToBids < ActiveRecord::Migration
  def change
    add_column :bids, :submitted_at, :datetime
  end
end
