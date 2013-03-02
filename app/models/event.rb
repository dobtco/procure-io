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
  include Rails.application.routes.url_helpers

  has_many :event_feeds
  has_one :users_event_feed, class_name: "EventFeed"
  belongs_to :targetable, polymorphic: :true

  default_scope order("created_at DESC")

  scope :include_users_event_feed, lambda { |user|
    joins("INNER JOIN event_feeds as users_event_feed ON users_event_feed.event_id = events.id")
    .where("users_event_feed.user_type = ? AND users_event_feed.user_id = ?", user.class.name, user.id)
  }

  def data
    ActiveSupport::JSON.decode(read_attribute(:data))
  end

  def path
    case event_type
    when "ProjectComment"
      comments_project_path(targetable_id)
    when "BidComment"
      project_bid_path(data['commentable']['project']['id'], targetable_id) + "#comment-page"
    when "BidAwarded", "BidUnawarded", "VendorBidAwarded", "VendorBidUnawarded", "VendorBidDismissed", "VendorBidUndismissed"
      project_bid_path(data['bid']['project']['id'], data['bid']['id'])
    end
  end

  def text
    case event_type
    when "ProjectComment"
      "#{data['officer']['name']} commented on #{data['commentable']['title']}."
    when "BidComment"
      "#{data['officer']['name']} commented on #{data['commentable']['vendor']['name']}'s bid for #{data['commentable']['project']['title']}."
    when "BidAwarded", "BidUnawarded"
      "#{data['officer']['name']} #{event_type == 'BidAwarded' ? 'awarded' : 'unawarded'} #{data['bid']['vendor']['name']}'s bid on #{data['bid']['project']['title']}."
    when "VendorBidAwarded"
      "#{data['officer']['name']} has awarded your bid on #{data['bid']['project']['title']}."
    when "VendorBidUnawarded"
      "#{data['officer']['name']} has unawarded your bid on #{data['bid']['project']['title']}."
    when "VendorBidDismissed"
      "#{data['officer']['name']} has dismissed your bid on #{data['bid']['project']['title']}."
    when "VendorBidUndismissed"
      "#{data['officer']['name']} has undismissed your bid on #{data['bid']['project']['title']}."
    end
  end
end
