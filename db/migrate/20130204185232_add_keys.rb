class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "bids", "projects", :name => "bids_project_id_fk"
    add_foreign_key "bids", "vendors", :name => "bids_vendor_id_fk"
    add_foreign_key "collaborators", "officers", :name => "collaborators_officer_id_fk"
    add_foreign_key "collaborators", "projects", :name => "collaborators_project_id_fk"
  end
end
