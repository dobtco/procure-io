# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string(255)
#  commentable_id   :integer
#  officer_id       :integer
#  vendor_id        :integer
#  comment_type     :string(255)
#  body             :text
#  data             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :officer
  belongs_to :vendor

  has_many :events, as: :targetable

  serialize :data

  after_save :calculate_commentable_total_comments!
  after_create :subscribe_officer_if_never_subscribed!
  after_create do
    return if comment_type # don't proceed if this is an automatically-generated comment
    self.delay.generate_events
  end

  default_scope order("created_at")

  private
  def calculate_commentable_total_comments!
    commentable.calculate_total_comments!
  end

  def subscribe_officer_if_never_subscribed!
    return if comment_type # don't proceed if this is an automatically-generated comment
    return unless commentable.class.name == "Bid"

    if !commentable.ever_watched_by?(officer)
      officer.watch!("Bid", commentable.id)
    end
  end

  def generate_events
    if self.commentable.class.name == "Project"
      event = commentable.events.create(event_type: "ProjectComment", data: CommentSerializer.new(self, root: false).to_json)

      commentable.watches.where(user_type: "Officer").where("user_id != ?", officer.id).each do |watch|
        EventFeed.create(event_id: event.id, user_id: watch.user_id, user_type: "Officer")
      end

    elsif self.commentable.class.name == "Bid"
      # subscribe to future comments unless user has already unsubscribed
      event = commentable.events.create(event_type: "BidComment", data: CommentSerializer.new(self, root: false).to_json)

      commentable.watches.where(user_type: "Officer").where("user_id != ?", officer.id).each do |watch|
        EventFeed.create(event_id: event.id, user_id: watch.user_id, user_type: "Officer")
      end
    end
  end
end
