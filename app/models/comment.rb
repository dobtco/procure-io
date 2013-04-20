# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string(255)
#  commentable_id   :integer
#  officer_id       :integer
#  comment_type     :string(255)
#  body             :text
#  data             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :officer

  has_many :events, as: :targetable

  serialize :data

  after_save :calculate_commentable_total_comments!
  after_create :subscribe_officer_if_never_subscribed!
  after_create :generate_events

  default_scope order("created_at")

  private
  def calculate_commentable_total_comments!
    commentable.calculate_total_comments!
  end

  def subscribe_officer_if_never_subscribed!
    return if comment_type # don't proceed if this is an automatically-generated comment
    return unless commentable && commentable.class.name == "Bid"

    if !commentable.ever_watched_by?(officer)
      officer.user.watch!("Bid", commentable.id)
    end
  end

  def generate_events
    return if comment_type # don't proceed if this is an automatically-generated comment
    method_name = :"generate_events_for_#{commentable.class.name.downcase}"
    self.send(method_name) if self.respond_to?(method_name)
  end

  handle_asynchronously :generate_events

  def generate_events_for_project
    event = commentable.events.create(event_type: Event.event_types[:project_comment],
                                      data: CommentSerializer.new(self, root: false).to_json)

    commentable.watches.not_disabled.where_user_is_officer.where("user_id != ?", officer.user.id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end
  end

  def generate_events_for_bid
    # subscribe to future comments unless user has already unsubscribed
    event = commentable.events.create(event_type: Event.event_types[:bid_comment],
                                      data: CommentSerializer.new(self, root: false).to_json)

    commentable.watches.not_disabled.where_user_is_officer.where("user_id != ?", officer.user.id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end
  end
end
