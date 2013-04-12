class CreateWatches < ActiveRecord::Migration
  def change
    create_table :watches do |t|
      t.integer :user_id
      t.integer :watchable_id
      t.string :watchable_type
      t.boolean :disabled, default: false

      t.timestamps
    end
  end
end
