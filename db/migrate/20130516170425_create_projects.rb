class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.datetime :bids_due_at
      t.integer :organization_id
      t.datetime :posted_at
      t.integer :poster_id
      t.integer :total_comments, default: 0
      t.text :form_options
      t.text :abstract
      t.boolean :featured
      t.datetime :question_period_ends_at
      t.integer :review_mode, default: 1
      t.integer :total_submitted_bids, default: 0
      t.boolean :solicit_bids
      t.boolean :review_bids

      t.timestamps
    end

    add_index :projects, :slug, unique: true
  end
end
