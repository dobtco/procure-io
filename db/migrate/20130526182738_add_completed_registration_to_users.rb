class AddCompletedRegistrationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :completed_registration, :boolean, default: false
  end
end
