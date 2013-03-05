class AddAddedByOfficerIdToCollaborators < ActiveRecord::Migration
  def change
    add_column :collaborators, :added_by_officer_id, :integer
  end
end
