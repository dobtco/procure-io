class CreateBidsLabels < ActiveRecord::Migration
  def change
    create_table :bids_labels, id: false do |t|
      t.integer :bid_id
      t.integer :label_id
    end

    add_foreign_key "bids_labels", "bids", :name => "bids_labels_bid_id_fk"
    add_foreign_key "bids_labels", "labels", :name => "bids_labels_label_id_fk"
  end
end
