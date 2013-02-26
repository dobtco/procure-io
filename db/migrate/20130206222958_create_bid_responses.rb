class CreateBidResponses < ActiveRecord::Migration
  def change
    create_table :bid_responses do |t|
      t.integer :bid_id
      t.integer :response_field_id
      t.text :value

      t.timestamps
    end
  end
end
