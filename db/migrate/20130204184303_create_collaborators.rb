class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators, id: false do |t|
      t.integer :project_id
      t.integer :officer_id
      t.boolean :owner
    end
  end
end
