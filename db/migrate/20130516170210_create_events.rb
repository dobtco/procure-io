class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :data
      t.string :targetable_type
      t.integer :targetable_id
      t.integer :event_type

      t.timestamps
    end
  end
end
