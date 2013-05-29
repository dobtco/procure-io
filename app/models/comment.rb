# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string(255)
#  commentable_id   :integer
#  user_id          :integer
#  body             :text
#  data             :text
#  created_at       :datetime
#  updated_at       :datetime
#

class Comment < ActiveRecord::Base
  include SerializationHelper
  include Behaviors::TargetableForEvents

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :user

  serialize :data

  after_save :calculate_commentable_total_comments!
  after_destroy :calculate_commentable_total_comments!
  after_create :subscribe_user_if_never_subscribed!
  after_create :generate_events

  default_scope -> { order("created_at") }

  private
  def calculate_commentable_total_comments!
    commentable.calculate_total_comments!
  end

  def subscribe_user_if_never_subscribed!
    user.watch!(commentable) if !commentable.ever_watched_by?(user)
  end

  def generate_events
    event_data = { comment: serialized(self, include_commentable: true) }

    if commentable.class.name == "Bid"
      event_data[:project] = serialized(commentable.project)
    end

    commentable.create_events(:"#{commentable.class.name.downcase}_comment",
                              commentable.active_watchers(not_users: user, user_can: :read_comments_on),
                              event_data)
  end

  handle_asynchronously :generate_events
end
