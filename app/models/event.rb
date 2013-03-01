# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  event_type      :string(255)
#  data            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  targetable_type :string(255)
#  targetable_id   :integer
#

class Event < ActiveRecord::Base
  has_many :event_feeds
  has_one :users_event_feed, class_name: "EventFeed"
  belongs_to :targetable, polymorphic: :true

  scope :include_users_event_feed, lambda { |user|
    joins("INNER JOIN event_feeds as users_event_feed ON users_event_feed.event_id = events.id")
    .where("users_event_feed.user_type = ? AND users_event_feed.user_id = ?", user.class.name, user.id)
  }

  serialize :data
end
