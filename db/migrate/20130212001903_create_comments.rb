class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :commentable_type
      t.integer :commentable_id
      t.integer :officer_id
      t.integer :vendor_id
      t.string :comment_type
      t.text :body
      t.text :data

      t.timestamps
    end

    add_foreign_key "comments", "officers", :name => "comments_officer_id_fk"
    add_foreign_key "comments", "vendors", :name => "comments_vendor_id_fk"
  end
end
