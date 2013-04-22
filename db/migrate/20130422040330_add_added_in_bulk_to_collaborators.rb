class AddAddedInBulkToCollaborators < ActiveRecord::Migration
  def change
    add_column :collaborators, :added_in_bulk, :boolean
  end
end
