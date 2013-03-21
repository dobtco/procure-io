class AddAbstractToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :abstract, :string
  end
end
