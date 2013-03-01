# == Schema Information
#
# Table name: officers
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  title                  :string(255)
#  invitation_token       :string(60)
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
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

  has_many :event_feeds, as: :user
  has_many :events, through: :event_feeds, select: 'events.*, event_feeds.read as read'

  has_many :officer_watches

  def signed_up?
    self.encrypted_password != "" ? true : false
  end

  def watches?(watchable_type, watchable_id)
    officer_watches.where(watchable_type: watchable_type, watchable_id: watchable_id, disabled: false).first ? true : false
  end

  def watch!(watchable_type, watchable_id)
    officer_watch = officer_watches.where(watchable_type: watchable_type, watchable_id: watchable_id).first_or_create
    if officer_watch.disabled then officer_watch.update_attributes(disabled: false) end
  end

  def unwatch!(watchable_type, watchable_id)
    officer_watches.where(watchable_type: watchable_type, watchable_id: watchable_id).first.update_attributes(disabled: true)
  end
end
