class User < ActiveRecord::Base
  attr_accessible :crypted_password, :email, :notification_preferences, :owner_id, :owner_type, :password_salt, :persistence_token
end
