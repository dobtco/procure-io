class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.integer :project_id
      t.string :name
      t.string :color

      t.timestamps
    end

    add_foreign_key "labels", "projects", :name => "labels_project_id_fk"
  end
end
