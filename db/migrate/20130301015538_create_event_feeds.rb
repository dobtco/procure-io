class CreateEventFeeds < ActiveRecord::Migration
  def change
    create_table :event_feeds do |t|
      t.integer :event_id
      t.integer :user_id
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
