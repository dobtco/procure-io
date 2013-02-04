class AddFieldsToOfficers < ActiveRecord::Migration
  def change
    add_column :officers, :name, :string
    add_column :officers, :title, :string
  end
end
