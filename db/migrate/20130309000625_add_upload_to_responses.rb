class AddUploadToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :upload, :string
  end
end
