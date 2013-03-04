class CreateBidResponses < ActiveRecord::Migration
  def change
    create_table :bid_responses do |t|
      t.integer :bid_id
      t.integer :response_field_id
      t.text :value

      t.timestamps
    end

    add_foreign_key "bid_responses", "bids", :name => "bid_responses_bid_id_fk"
    add_foreign_key "bid_responses", "response_fields", :name => "bid_responses_response_field_id_fk"
  end
end
