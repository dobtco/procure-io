class CreateSavedSearches < ActiveRecord::Migration
  def change
    create_table :saved_searches do |t|
      t.integer :user_id
      t.text :search_parameters
      t.string :name
      t.datetime :last_emailed_at

      t.timestamps
    end
  end
end
