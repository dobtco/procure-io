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
  include PgSearch

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :bids, dependent: :destroy
  has_many :questions
  has_many :saved_searches, dependent: :destroy

  has_many :watches, as: :user

  has_one :vendor_profile, dependent: :destroy
  has_many :responses, through: :vendor_profile

  serialize :notification_preferences
  before_create :set_default_notification_preferences

  pg_search_scope :full_search, associated_against: { responses: [:value] },
                                using: {
                                  tsearch: {prefix: true}
                                }


  def self.search_by_params(params, count_only = false)
    return_object = { meta: {} }
    return_object[:meta][:page] = [params[:page].to_i, 1].max
    return_object[:meta][:per_page] = 10 # [params[:per_page].to_i, 10].max

    query = Vendor

    if params[:sort] == "stars"
      query = query.order("total_stars #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
    elsif params[:sort] == "name" || !params[:sort]
      query = query.order("name #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
    end

    if params[:q] && !params[:q].blank?
      query = query.full_search(params[:q])
    end

    return query.count if count_only

    return_object[:meta][:total] = query.count
    return_object[:meta][:last_page] = [(return_object[:meta][:total].to_f / return_object[:meta][:per_page]).ceil, 1].max
    return_object[:page] = [return_object[:meta][:last_page], return_object[:meta][:page]].min

    return_object[:results] = query.limit(return_object[:meta][:per_page])
                                   .offset((return_object[:meta][:page] - 1)*return_object[:meta][:per_page])

    return_object
  end


  def self.event_types
    types = [:project_amended]
    types.push(:question_answered) if GlobalConfig.instance[:questions_enabled]
    types.push(:vendor_bid_awarded, :vendor_bid_unawarded, :vendor_bid_dismissed, :vendor_bid_undismissed) if GlobalConfig.instance[:bid_submission_enabled]
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
