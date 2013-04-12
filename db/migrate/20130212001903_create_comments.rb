class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :commentable_type
      t.integer :commentable_id
      t.integer :officer_id
      t.string :comment_type
      t.text :body
      t.text :data

      t.timestamps
    end

    add_foreign_key "comments", "officers", :name => "comments_officer_id_fk"
  end
end
