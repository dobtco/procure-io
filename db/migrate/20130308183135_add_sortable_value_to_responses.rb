class AddSortableValueToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :sortable_value, :string
  end
end
