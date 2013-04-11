# == Schema Information
#
# Table name: officers
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  title      :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Officer < ActiveRecord::Base
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
