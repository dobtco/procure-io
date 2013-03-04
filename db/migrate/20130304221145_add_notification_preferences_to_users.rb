class AddNotificationPreferencesToUsers < ActiveRecord::Migration
  def change
    add_column :vendors, :notification_preferences, :text
    add_column :officers, :notification_preferences, :text
  end
end
