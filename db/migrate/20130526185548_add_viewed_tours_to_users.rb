class AddViewedToursToUsers < ActiveRecord::Migration
  def change
    add_column :users, :viewed_tours, :text
  end
end
