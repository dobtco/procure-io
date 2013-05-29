class CreateAmendments < ActiveRecord::Migration
  def change
    create_table :amendments do |t|
      t.integer :project_id
      t.text :body
      t.datetime :posted_at
      t.integer :poster_id
      t.string :title

      t.timestamps
    end
  end
end
