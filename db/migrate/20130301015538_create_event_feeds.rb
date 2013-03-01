class CreateEventFeeds < ActiveRecord::Migration
  def change
    create_table :event_feeds do |t|
      t.integer :event_id
      t.string :user_type
      t.integer :user_id
      t.boolean :read

      t.timestamps
    end
  end
end
