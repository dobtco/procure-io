# == Schema Information
#
# Table name: vendors
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      default(""), not null
#  encrypted_password       :string(255)      default(""), not null
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
#  notification_preferences :text
#  account_disabled         :boolean          default(FALSE)
#

class Vendor < ActiveRecord::Base
  include SharedUserMethods

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :bids, dependent: :destroy
  has_many :questions
  has_many :saved_searches, dependent: :destroy

  has_many :watches, as: :user

  serialize :notification_preferences
  before_create :set_default_notification_preferences

  def self.event_types
    types = [:project_amended]
    types.push(:vendor_bid_awarded, :vendor_bid_unawarded, :vendor_bid_dismissed, :vendor_bid_undismissed) if PROCURE_IO_CONFIG[:bid_submission_enabled]
    Event.event_types.only(*types)
  end

  def bid_for_project(project)
    bids.where(project_id: project.id).first
  end

  def submitted_bid_for_project(project)
    bids.where("submitted_at IS NOT NULL").where(project_id: project.id).first
  end

  def active_for_authentication?
    super && !self.account_disabled?
  end

  private
  def set_default_notification_preferences
    self.notification_preferences = Vendor.event_types.values
  end
end
