class CreateOfficerWatches < ActiveRecord::Migration
  def change
    create_table :officer_watches do |t|
      t.integer :officer_id
      t.integer :watchable_id
      t.string :watchable_type

      t.timestamps
    end
  end
end
