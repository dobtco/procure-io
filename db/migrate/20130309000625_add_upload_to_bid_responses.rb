class AddUploadToBidResponses < ActiveRecord::Migration
  def change
    add_column :bid_responses, :upload, :string
  end
end
