class AddSortableValueToBidResponses < ActiveRecord::Migration
  def change
    add_column :bid_responses, :sortable_value, :string
  end
end
