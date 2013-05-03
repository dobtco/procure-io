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
#  perishable_token         :string(255)      default(""), not null
#  last_login_at            :datetime
#  current_login_at         :datetime
#  last_login_ip            :string(255)
#  current_login_ip         :string(255)
#

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.require_password_confirmation = false
    c.validate_password_field = false
    c.disable_perishable_token_maintenance = true
  end

  belongs_to :owner, polymorphic: true, touch: true

  has_many :event_feeds
  has_many :events, -> { select('events.*, event_feeds.read as read') }, through: :event_feeds
  has_many :watches

  serialize :notification_preferences
  before_create :set_default_notification_preferences

  def is_vendor?
    owner.class.name == "Vendor"
  end

  def is_officer?
    owner.class.name == "Officer"
  end

  # Expire tokens only for password reset, not for invites.
  def self.find_for_invite_or_password_reset_token(token)
    user = User.find_using_perishable_token(token, nil)

    if user.signed_up?
      user = User.find_using_perishable_token(token, 3.days)
    end

    user
  end

  def signed_up?
    (crypted_password || current_login_at || last_login_at) ? true : false
  end

  def gravatar_url
    "//gravatar.com/avatar/#{Digest::MD5::hexdigest(email.downcase)}?size=45&d=identicon"
  end

  def read_notifications(targetable, *event_types)
    sql = targetable.events

    if event_types.any?
      sql = sql.where("event_type IN (?)", Event.event_types.only(*event_types).values)
    end

    event_feeds.where("event_id IN (?)", sql.pluck(:id)).update_all(read: true)
  end

  def unread_notification_count
    self.event_feeds.unread.count
  end

  def watches?(watchable)
    watches.where(watchable_type: watchable.class.name, watchable_id: watchable.id, disabled: false).first ? true : false
  end

  def watch!(watchable)
    watch = watches.where(watchable_type: watchable.class.name, watchable_id: watchable.id).first_or_create
    if watch.disabled then watch.update_attributes(disabled: false) end
  end

  def unwatch!(watchable)
    watches.where(watchable_type: watchable.class.name, watchable_id: watchable.id).first.update_attributes(disabled: true)
  end

  def send_email_notifications_for?(event_type_value)
    self.notification_preferences && self.notification_preferences.include?(event_type_value)
  end

  def set_default_notification_preferences
    self.notification_preferences = owner.default_notification_preferences
  end

  def send_reset_password_instructions!
    Mailer.password_reset_email(self).deliver
  end

  def can_receive_event(event)
    # Currently, vendors can receive all events
    return true if is_vendor?

    ability = Ability.new(self)

    case Event.event_types[event.event_type]
    when :project_comment
      ability.can? :read_and_write_project_comments, event.targetable
    when :bid_comment
      ability.can? :read_and_write_bid_comments, event.targetable.project
    when :bid_awarded, :bid_unawarded, :bid_submitted
      ability.can? :review_bids, event.targetable.project
    when :collaborator_added, :bulk_collaborators_added
      ability.can? :collaborate_on, event.targetable
    when :question_asked
      ability.can? :collaborate_on, event.targetable
    else
      true
    end
  end
end
