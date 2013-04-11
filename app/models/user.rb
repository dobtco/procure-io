# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  notification_preferences :text
#  owner_id                 :integer
#  owner_type               :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :crypted_password, :email, :notification_preferences, :owner_id, :owner_type, :password_salt, :persistence_token
end
