class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.integer :project_id
      t.string :name
      t.string :color

      t.timestamps
    end
  end
end
