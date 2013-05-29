class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :project_id
      t.integer :asker_id
      t.integer :answerer_id
      t.text :body
      t.text :answer_body

      t.timestamps
    end
  end
end
