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
  end
end
