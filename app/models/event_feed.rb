# == Schema Information
#
# Table name: event_feeds
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  user_type  :string(255)
#  user_id    :integer
#  read       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EventFeed < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :event
end
