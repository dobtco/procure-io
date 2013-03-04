class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :project_id
      t.integer :vendor_id
      t.integer :officer_id
      t.text :body
      t.text :answer_body

      t.timestamps
    end

    add_foreign_key "questions", "officers", :name => "questions_officer_id_fk"
    add_foreign_key "questions", "projects", :name => "questions_project_id_fk"
    add_foreign_key "questions", "vendors", :name => "questions_vendor_id_fk"
  end
end
