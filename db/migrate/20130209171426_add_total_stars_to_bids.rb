class AddTotalStarsToBids < ActiveRecord::Migration
  def change
    add_column :bids, :total_stars, :integer, null: false, default: 0
  end
end
