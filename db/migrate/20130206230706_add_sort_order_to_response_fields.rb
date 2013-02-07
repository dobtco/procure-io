class AddSortOrderToResponseFields < ActiveRecord::Migration
  def change
    add_column :response_fields, :sort_order, :integer, null: false
  end
end
