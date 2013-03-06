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
#

class Officer < ActiveRecord::Base
  include SharedUserMethods

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :collaborators
  has_many :projects, through: :collaborators, uniq: true
  has_many :questions
  has_many :bid_reviews, dependent: :destroy

  serialize :notification_preferences
  before_create :set_default_notification_preferences

  def self.event_types
    Event.event_types.only(:project_comment, :bid_comment, :bid_awarded, :bid_unawarded, :collaborator_added, :you_were_added)
  end

  def signed_up?
    self.encrypted_password != "" ? true : false
  end

  private
  def set_default_notification_preferences
    self.notification_preferences = Officer.event_types.except(:collaborator_added).values
  end
end
