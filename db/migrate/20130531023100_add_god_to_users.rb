class AddGodToUsers < ActiveRecord::Migration
  def change
    add_column :users, :god, :boolean, default: false
  end
end
