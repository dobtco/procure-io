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
#  created_at       :datetime
#  updated_at       :datetime
#

class Comment < ActiveRecord::Base
  include SerializationHelper
  include Behaviors::TargetableForEvents

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :officer

  serialize :data

  after_save :calculate_commentable_total_comments!
  after_create :subscribe_officer_if_never_subscribed!
  after_create :generate_events

  default_scope -> { order("created_at") }

  private
  def calculate_commentable_total_comments!
    commentable.calculate_total_comments!
  end

  def subscribe_officer_if_never_subscribed!
    return if comment_type # don't proceed if this is an automatically-generated comment
    return unless commentable && commentable.class.name == "Bid" # only proceed if commentable is a bid

    if !commentable.ever_watched_by?(officer)
      officer.user.watch!(commentable)
    end
  end

  def generate_events
    return if comment_type # don't proceed if this is an automatically-generated comment

    event_data = { comment: serialized(self, include_commentable: true) }

    if commentable.class.name == "Bid"
      event_data[:project] = serialized(commentable.project)
    end

    commentable.create_events(:"#{commentable.class.name.downcase}_comment",
                              commentable.active_watchers(:officer, not_users: officer.user),
                              event_data)
  end

  handle_asynchronously :generate_events
end
