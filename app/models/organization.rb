# == Schema Information
#
# Table name: organizations
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  email       :string(255)
#  username    :string(255)
#  logo        :string(255)
#  event_hooks :text
#  created_at  :datetime
#  updated_at  :datetime
#

require_dependency 'enum'

class Organization < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username

  include Behaviors::TargetableForEvents

  has_many :form_templates
  has_many :projects
  has_many :roles
  has_many :teams, dependent: :destroy
  has_many :organization_team_members, -> { uniq }, through: :teams
  has_many :users, -> { uniq }, through: :organization_team_members
  has_many :registrations, dependent: :destroy
  has_many :vendor_registrations, through: :registrations

  after_create :create_owners_team!

  serialize :event_hooks, Hash

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :email, presence: true, email: true

  validates :username, presence: true, length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-zA-Z0-9]+\z/, message: "Only letters and numbers allowed" },
            uniqueness: { case_sensitive: false }

  validate :username_is_not_already_a_route

  mount_uploader :logo, LogoUploader

  def self.event_hooks
    @event_hooks ||= Enum.new(
      :twitter, :custom_http
    )
  end

  def self.event_hook_name_for(event_hook)
    {
      :twitter => "Twitter",
      :custom_http => "Custom HTTP"
    }[event_hook.to_sym]
  end

  def run_event_hooks_for_project!(project)
    event_hooks.select { |k, v| v['enabled'] }.each do |k, v|
      case k
      when GlobalConfig.event_hooks[:twitter]
        client = ProcureIoTwitterOAuth.client(token: v['oauth_token'], secret: v['oauth_token_secret'])
        client.update(
          truncate(v['tweet_body'].gsub(':title', project.title)
                                  .gsub(':bids_due_at', project.bids_due_at.to_formatted_s(:readable_dateonly)),
                   length: 140)
        )

      when GlobalConfig.event_hooks[:custom_http]
        HTTParty.post(v['url'],
                      body: ProjectSerializer.new(project, root: false).to_json,
                      headers: { 'Content-Type' => 'application/json' } ) rescue ArgumentError
      end
    end
  end

  def username=(x)
    write_attribute(:username, x.downcase)
  end

  def owners_team
    teams.where("permission_level = ?", Team.permission_levels[:owner]).first
  end

  after_validation :move_friendly_id_error_to_username

  def move_friendly_id_error_to_username
    if (error = errors.messages.delete(:friendly_id))
      errors.messages[:username] = error
    end
  end

  handle_asynchronously :run_event_hooks_for_project!

  private
  def create_owners_team!
    teams.create(name: "Owners", permission_level: Team.permission_levels[:owner])
  end

  def username_is_not_already_a_route
    return if username.blank?
    if (path = Rails.application.routes.recognize_path(username)) &&
       !(path[:controller] == 'organizations' && path[:action] == 'show')
      errors.add(:username, "is reserved")
    end
  end
end
