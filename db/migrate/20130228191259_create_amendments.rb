class CreateAmendments < ActiveRecord::Migration
  def change
    create_table :amendments do |t|
      t.integer :project_id
      t.text :body
      t.datetime :posted_at
      t.integer :posted_by_officer_id

      t.timestamps
    end
  end
end
