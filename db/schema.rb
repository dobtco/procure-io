# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130319015840) do

  create_table "amendments", :force => true do |t|
    t.integer  "project_id"
    t.text     "body"
    t.datetime "posted_at"
    t.integer  "posted_by_officer_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.text     "title"
  end

  create_table "bid_responses", :force => true do |t|
    t.integer  "bid_id"
    t.integer  "response_field_id"
    t.text     "value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "sortable_value"
    t.string   "upload"
  end

  create_table "bid_reviews", :force => true do |t|
    t.boolean  "starred"
    t.boolean  "read"
    t.integer  "officer_id"
    t.integer  "bid_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bids", :force => true do |t|
    t.integer  "vendor_id"
    t.integer  "project_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.datetime "submitted_at"
    t.datetime "dismissed_at"
    t.integer  "dismissed_by_officer_id"
    t.integer  "total_stars",             :default => 0, :null => false
    t.integer  "total_comments",          :default => 0, :null => false
    t.datetime "awarded_at"
    t.integer  "awarded_by_officer_id"
  end

  create_table "bids_labels", :id => false, :force => true do |t|
    t.integer "bid_id"
    t.integer "label_id"
  end

  create_table "collaborators", :force => true do |t|
    t.integer  "project_id"
    t.integer  "officer_id"
    t.boolean  "owner"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "added_by_officer_id"
  end

  create_table "comments", :force => true do |t|
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.integer  "officer_id"
    t.integer  "vendor_id"
    t.string   "comment_type"
    t.text     "body"
    t.text     "data"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "event_feeds", :force => true do |t|
    t.integer  "event_id"
    t.string   "user_type"
    t.integer  "user_id"
    t.boolean  "read",       :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "events", :force => true do |t|
    t.text     "data"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "targetable_type"
    t.integer  "targetable_id"
    t.integer  "event_type",      :limit => 2
  end

  create_table "form_templates", :force => true do |t|
    t.string   "name"
    t.text     "response_fields"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.text     "form_description"
    t.text     "form_confirmation_message"
  end

  create_table "labels", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "color"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "officers", :force => true do |t|
    t.string   "email",                                  :default => "", :null => false
    t.string   "encrypted_password",                     :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "name"
    t.string   "title"
    t.string   "invitation_token",         :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.text     "notification_preferences"
    t.string   "authentication_token"
  end

  add_index "officers", ["authentication_token"], :name => "index_officers_on_authentication_token", :unique => true
  add_index "officers", ["email"], :name => "index_officers_on_email", :unique => true
  add_index "officers", ["invitation_token"], :name => "index_officers_on_invitation_token"
  add_index "officers", ["invited_by_id"], :name => "index_officers_on_invited_by_id"
  add_index "officers", ["reset_password_token"], :name => "index_officers_on_reset_password_token", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "bids_due_at"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.datetime "posted_at"
    t.integer  "posted_by_officer_id"
    t.integer  "total_comments",            :default => 0, :null => false
    t.boolean  "has_unsynced_body_changes"
    t.text     "form_description"
    t.text     "form_confirmation_message"
  end

  create_table "projects_tags", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "tag_id"
  end

  create_table "questions", :force => true do |t|
    t.integer  "project_id"
    t.integer  "vendor_id"
    t.integer  "officer_id"
    t.text     "body"
    t.text     "answer_body"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "response_fields", :force => true do |t|
    t.integer  "project_id"
    t.string   "label"
    t.string   "field_type"
    t.text     "field_options"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "sort_order",    :null => false
    t.boolean  "key_field"
  end

  create_table "saved_searches", :force => true do |t|
    t.integer  "vendor_id"
    t.text     "search_parameters"
    t.string   "name"
    t.datetime "last_emailed_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "vendors", :force => true do |t|
    t.string   "email",                    :default => "",    :null => false
    t.string   "encrypted_password",       :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "name"
    t.text     "notification_preferences"
    t.boolean  "account_disabled",         :default => false
  end

  add_index "vendors", ["email"], :name => "index_vendors_on_email", :unique => true
  add_index "vendors", ["reset_password_token"], :name => "index_vendors_on_reset_password_token", :unique => true

  create_table "watches", :force => true do |t|
    t.string   "user_type"
    t.integer  "user_id"
    t.integer  "watchable_id"
    t.string   "watchable_type"
    t.boolean  "disabled",       :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_foreign_key "amendments", "officers", :name => "amendments_posted_by_officer_id_fk", :column => "posted_by_officer_id"
  add_foreign_key "amendments", "projects", :name => "amendments_project_id_fk"

  add_foreign_key "bid_responses", "bids", :name => "bid_responses_bid_id_fk"
  add_foreign_key "bid_responses", "response_fields", :name => "bid_responses_response_field_id_fk"

  add_foreign_key "bid_reviews", "bids", :name => "bid_reviews_bid_id_fk"
  add_foreign_key "bid_reviews", "officers", :name => "bid_reviews_officer_id_fk"

  add_foreign_key "bids", "projects", :name => "bids_project_id_fk"
  add_foreign_key "bids", "vendors", :name => "bids_vendor_id_fk"

  add_foreign_key "bids_labels", "bids", :name => "bids_labels_bid_id_fk"
  add_foreign_key "bids_labels", "labels", :name => "bids_labels_label_id_fk"

  add_foreign_key "collaborators", "officers", :name => "collaborators_officer_id_fk"
  add_foreign_key "collaborators", "projects", :name => "collaborators_project_id_fk"

  add_foreign_key "comments", "officers", :name => "comments_officer_id_fk"
  add_foreign_key "comments", "vendors", :name => "comments_vendor_id_fk"

  add_foreign_key "event_feeds", "events", :name => "event_feeds_event_id_fk"

  add_foreign_key "labels", "projects", :name => "labels_project_id_fk"

  add_foreign_key "projects", "officers", :name => "projects_posted_by_officer_id_fk", :column => "posted_by_officer_id"

  add_foreign_key "projects_tags", "projects", :name => "projects_tags_project_id_fk"
  add_foreign_key "projects_tags", "tags", :name => "projects_tags_tag_id_fk"

  add_foreign_key "questions", "officers", :name => "questions_officer_id_fk"
  add_foreign_key "questions", "projects", :name => "questions_project_id_fk"
  add_foreign_key "questions", "vendors", :name => "questions_vendor_id_fk"

  add_foreign_key "response_fields", "projects", :name => "response_fields_project_id_fk"

  add_foreign_key "saved_searches", "vendors", :name => "saved_searches_vendor_id_fk"

end
