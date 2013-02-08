class AddKeyFieldToResponseFields < ActiveRecord::Migration
  def change
    add_column :response_fields, :key_field, :boolean
  end
end
