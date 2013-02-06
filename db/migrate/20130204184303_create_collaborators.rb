class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.integer :project_id
      t.integer :officer_id
      t.boolean :owner

      t.timestamps
    end
  end
end
