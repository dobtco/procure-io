# == Schema Information
#
# Table name: officers
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      default(""), not null
#  encrypted_password       :string(255)      default("")
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  name                     :string(255)
#  title                    :string(255)
#  invitation_token         :string(60)
#  invitation_sent_at       :datetime
#  invitation_accepted_at   :datetime
#  invitation_limit         :integer
#  invited_by_id            :integer
#  invited_by_type          :string(255)
#  notification_preferences :text
#  authentication_token     :string(255)
#  role_id                  :integer
#

class Officer < ActiveRecord::Base
  include SharedUserMethods

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  has_many :collaborators
  has_many :projects, through: :collaborators, uniq: true
  has_many :questions
  has_many :bid_reviews, dependent: :destroy

  belongs_to :role

  serialize :notification_preferences
  before_create :set_default_notification_preferences
  before_create :reset_authentication_token

  def self.event_types
    types = [:collaborator_added, :you_were_added]
    types.push(:question_asked) if GlobalConfig.instance[:questions_enabled]
    types.push(:project_comment) if GlobalConfig.instance[:comments_enabled]
    types.push(:bid_comment) if GlobalConfig.instance[:bid_review_enabled] && GlobalConfig.instance[:comments_enabled]
    types.push(:bid_awarded, :bid_unawarded) if GlobalConfig.instance[:bid_review_enabled]
    Event.event_types.only(*types)
  end

  def signed_up?
    self.encrypted_password != "" ? true : false
  end

  def permission_level
    if role
      Role.permission_levels[role.permission_level]
    else
      :user
    end
  end

  private
  def set_default_notification_preferences
    self.notification_preferences = Officer.event_types.except(:collaborator_added).values
  end
end
