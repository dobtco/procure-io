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

ActiveRecord::Schema.define(:version => 20130205004911) do

  create_table "bids", :force => true do |t|
    t.integer  "vendor_id"
    t.integer  "project_id"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "collaborators", :force => true do |t|
    t.integer "project_id"
    t.integer "officer_id"
    t.boolean "owner"
  end

  create_table "officers", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "title"
  end

  add_index "officers", ["email"], :name => "index_officers_on_email", :unique => true
  add_index "officers", ["reset_password_token"], :name => "index_officers_on_reset_password_token", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "bids_due_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "posted"
  end

  create_table "vendors", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "vendors", ["email"], :name => "index_vendors_on_email", :unique => true
  add_index "vendors", ["reset_password_token"], :name => "index_vendors_on_reset_password_token", :unique => true

  add_foreign_key "bids", "projects", :name => "bids_project_id_fk"
  add_foreign_key "bids", "vendors", :name => "bids_vendor_id_fk"

  add_foreign_key "collaborators", "officers", :name => "collaborators_officer_id_fk"
  add_foreign_key "collaborators", "projects", :name => "collaborators_project_id_fk"

end
