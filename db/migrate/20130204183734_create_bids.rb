class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :vendor_id
      t.integer :project_id
      t.text :body

      t.timestamps
    end

    add_foreign_key "bids", "projects", :name => "bids_project_id_fk"
    add_foreign_key "bids", "vendors", :name => "bids_vendor_id_fk"
  end
end
