class CreateProjectsTeams < ActiveRecord::Migration
  def change
    create_table :projects_teams, id: false do |t|
      t.integer :project_id
      t.integer :team_id
    end
  end
end
