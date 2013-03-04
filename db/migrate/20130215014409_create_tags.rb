class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end

    add_foreign_key "projects_tags", "tags", :name => "projects_tags_tag_id_fk"
  end
end
