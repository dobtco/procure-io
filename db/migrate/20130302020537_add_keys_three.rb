class AddKeysThree < ActiveRecord::Migration
  def change
    add_foreign_key "amendments", "officers", :name => "amendments_posted_by_officer_id_fk", :column => "posted_by_officer_id"
    add_foreign_key "amendments", "projects", :name => "amendments_project_id_fk"
    add_foreign_key "event_feeds", "events", :name => "event_feeds_event_id_fk"
    add_foreign_key "projects", "officers", :name => "projects_posted_by_officer_id_fk", :column => "posted_by_officer_id"
  end
end
