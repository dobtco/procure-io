class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :event_type
      t.text :data

      t.timestamps
    end

    add_foreign_key "event_feeds", "events", :name => "event_feeds_event_id_fk"
  end
end
