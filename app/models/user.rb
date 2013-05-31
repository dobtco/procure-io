# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  email                    :string(255)
#  notification_preferences :text
#  created_at               :datetime
#  updated_at               :datetime
#  encrypted_password       :string(128)
#  confirmation_token       :string(128)
#  remember_token           :string(128)
#  completed_registration   :boolean          default(FALSE)
#  viewed_tours             :text
#  god                      :boolean          default(FALSE)
#

require_dependency 'enum'

class User < ActiveRecord::Base
  include Clearance::User

  attr_accessor :is_inviting
  attr_accessor :is_admining
  attr_accessor :vendor_or_organization

  validates :password, length: { minimum: 6 }, unless: :password_optional?
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }, unless: :is_inviting

  has_many :questions_asked, class_name: "Question", foreign_key: "asker_id"
  has_many :questions_answerer, class_name: "Question", foreign_key: "answerer_id"
  has_many :bid_reviews, dependent: :destroy
  has_many :organization_team_members, -> { uniq }, dependent: :destroy
  has_many :teams, -> { uniq }, through: :organization_team_members
  has_many :organizations_where_admin, -> { where(teams: { permission_level: Team.permission_levels[:owner] }) }, through: :teams, source: :organization
  has_many :organizations, -> { order("organizations.name").uniq }, through: :teams
  has_many :projects, -> { uniq }, through: :teams
  has_many :event_feeds
  has_many :events, -> { select('events.*, event_feeds.read as read') }, through: :event_feeds
  has_many :watches
  has_many :vendor_team_members, dependent: :destroy
  has_many :vendors,
           -> { select('vendors.*, vendor_team_members.owner as owner').uniq.order("vendors.name") },
           through: :vendor_team_members
  has_many :bids, through: :vendors
  has_many :saved_searches, dependent: :destroy
  has_many :project_revisions, foreign_key: "saved_by_user_id"

  has_many :posted_projects, foreign_key: "poster_id", dependent: :nullify, class_name: "Project"

  serialize :notification_preferences, Hash
  serialize :viewed_tours, Array

  before_create :set_default_notification_preferences

  has_searcher

  pg_search_scope :full_search, against: [:name, :email],
                                using: {
                                  tsearch: { prefix: true }
                                }

  def self.add_params_to_query(query, params, args = {})
    if !params[:q].blank?
      query = query.full_search(params[:q])
    end

    direction = params[:direction] == 'desc' ? 'desc' : 'asc'

    if params[:sort] == "email"
      query = query.order("email #{direction}")

    elsif params[:sort] == "name" || params[:sort].blank?
      query = query.order("name #{direction}")
    end

    query
  end

  def highest_ranking_team_for_organization(organization)
    teams.where(organization_id: organization.id).order("permission_level desc").first
  end

  def display_name
    !name.blank? ? name : email
  end

  def is_vendor?
    vendor_team_members.first ? true : false
  end

  def is_officer?
    organization_team_members.first ? true : false
  end

  def signed_up?
    encrypted_password ? true : false
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

  def send_reset_password_instructions!
    Mailer.password_reset_email(self).deliver
  end

  def has_permission_to_receive_event?(event)
    # @screendoor
    true
  end

  def send_email_notifications_for?(event)
    case Event.event_types[event.event_type]
    when :import_finished
      false
    else
      notification_preferences_for(event.event_type) == User.notification_preference_values[:on_with_email] &&
      has_permission_to_receive_event?(event)
    end
  end

  def receives_event?(event)
    case Event.event_types[event.event_type]
    when :import_finished
      true
    else
      (User.notification_preference_values[:on] <= notification_preferences_for(event.event_type)) &&
      has_permission_to_receive_event?(event)
    end
  end

  def notification_preferences_for(event_key)
    key = case Event.event_types[event_key]
    when :added_to_organization_team, :added_to_vendor_team
      :added_to_team
    when :bid_awarded, :bid_unawarded
      :bid_awarded
    when :bid_dismissed, :bid_undismissed
      :bid_dismissed
    when :your_bid_awarded, :your_bid_unawarded
      :your_bid_awarded
    when :your_bid_dismissed, :your_bid_undismissed
      :your_bid_dismissed
    else
      Event.event_types[event_key]
    end

    self.notification_preferences[key] || User.notification_preference_values[:off]
  end

  def self.notification_preference_values
    @notification_preference_values ||= Enum.new(
      :off, :on, :on_with_email
    )
  end

  def self.notification_preference_choices
    {
      teams: {
        added_to_team: [:added_to_organization_team, :added_to_vendor_team],
        added_your_team_to_project: true
      },

      incoming_bids: {
        bid_submitted: true,
        bid_awarded: [:bid_awarded, :bid_unawarded],
        bid_dismissed: [:bid_dismissed, :bid_undismissed]
      },

      amendments: {
        project_amended: true
      },

      q_and_a: {
        question_asked: true,
        question_answered: true
      },

      comments: {
        bid_comment: true,
        project_comment: true
      },

      placed_bids: {
        your_bid_awarded: [:your_bid_awarded, :your_bid_unawarded],
        your_bid_dismissed: [:your_bid_dismissed, :your_bid_undismissed]
      }
    }
  end

  def notification_preference_choices
    filtered_choices = User.notification_preference_choices

    if !is_vendor?
      filtered_choices.delete(:placed_bids)
      filtered_choices.delete(:amendments)
      filtered_choices[:q_and_a].delete(:question_answered)

    elsif !is_officer?
      filtered_choices[:teams].delete(:added_your_team_to_project)
      filtered_choices.delete(:incoming_bids)
      filtered_choices[:q_and_a].delete(:question_asked)
      filtered_choices.delete(:comments)
    end

    filtered_choices
  end

  def self.invite!(email, inviter)
    user = User.new(email: email, is_inviting: true)
    user.send(:generate_confirmation_token)

    if user.save
      user.send_invite_email!(inviter)
      user
    end
  end

  def send_invite_email!(inviter)
    Mailer.invite_email(self, inviter).deliver
  end

  handle_asynchronously :send_invite_email!

  def authenticated?(password)
    encrypted_password.blank? ? false : super
  end

  def viewed_tour?(key)
    if viewed_tours.include?(key)
      true
    else
      update_attributes viewed_tours: viewed_tours.push(key)
      false
    end
  end

  private
  def password_optional?
    (is_admining || is_inviting) ? true : super
  end

  def set_default_notification_preferences
    new_notification_preferences = {}

    User.notification_preference_choices.values.each do |category|
      category.keys.each do |k|
        new_notification_preferences[k] = User.notification_preference_values[:on_with_email]
      end
    end

    self.notification_preferences = new_notification_preferences
  end
end
