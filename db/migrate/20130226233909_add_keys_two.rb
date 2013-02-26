class AddKeysTwo < ActiveRecord::Migration
  def change
    add_foreign_key "bid_responses", "bids", :name => "bid_responses_bid_id_fk"
    add_foreign_key "bid_responses", "response_fields", :name => "bid_responses_response_field_id_fk"
    add_foreign_key "bid_reviews", "bids", :name => "bid_reviews_bid_id_fk"
    add_foreign_key "bid_reviews", "officers", :name => "bid_reviews_officer_id_fk"
    add_foreign_key "bids_labels", "bids", :name => "bids_labels_bid_id_fk"
    add_foreign_key "bids_labels", "labels", :name => "bids_labels_label_id_fk"
    add_foreign_key "comments", "officers", :name => "comments_officer_id_fk"
    add_foreign_key "comments", "vendors", :name => "comments_vendor_id_fk"
    add_foreign_key "labels", "projects", :name => "labels_project_id_fk"
    add_foreign_key "projects_tags", "projects", :name => "projects_tags_project_id_fk"
    add_foreign_key "projects_tags", "tags", :name => "projects_tags_tag_id_fk"
    add_foreign_key "questions", "officers", :name => "questions_officer_id_fk"
    add_foreign_key "questions", "projects", :name => "questions_project_id_fk"
    add_foreign_key "questions", "vendors", :name => "questions_vendor_id_fk"
    add_foreign_key "response_fields", "projects", :name => "response_fields_project_id_fk"
    add_foreign_key "saved_searches", "vendors", :name => "saved_searches_vendor_id_fk"
  end
end
