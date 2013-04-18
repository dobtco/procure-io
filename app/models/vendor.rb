# == Schema Information
#
# Table name: vendors
#
#  id               :integer          not null, primary key
#  account_disabled :boolean
#  name             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Vendor < ActiveRecord::Base
  include SharedUserMethods
  include PgSearch
  include Searcher

  has_many :bids, dependent: :destroy
  has_many :questions
  has_many :saved_searches, dependent: :destroy

  has_many :watches, as: :user

  has_one :vendor_profile, dependent: :destroy
  has_many :responses, through: :vendor_profile

  pg_search_scope :full_search, against: [:name],
                                associated_against: { responses: [:value], user: [:email] },
                                using: { tsearch: { prefix: true } }

  has_searcher starting_query: Vendor.joins(:user).joins("LEFT JOIN vendor_profiles ON vendor_profiles.vendor_id = vendors.id")

  after_update :touch_all_bids!

  def self.add_params_to_query(query, params)
    if params[:sort].to_i > 0
      cast_int = ResponseField.find(params[:sort]).field_type.in?(ResponseField::SORTABLE_VALUE_INTEGER_FIELDS)
      query = query.joins(sanitize_sql_array(["LEFT JOIN responses ON responses.responsable_id = vendor_profiles.id
                                               AND responses.responsable_type = 'VendorProfile'
                                               AND responses.response_field_id = ?", params[:sort]]))
                   .order("CASE WHEN responses.response_field_id IS NULL then 1 else 0 end,
                           responses.sortable_value#{cast_int ? '::numeric' : ''} #{params[:direction] == 'asc' ? 'asc' : 'desc' }")

    elsif params[:sort] == "email"
      query = query.order("lower(users.email) #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
    elsif params[:sort] == "name" || !params[:sort]
      query = query.order("NULLIF(lower(name), '') #{params[:direction] == 'asc' ? 'asc NULLS LAST' : 'desc' }")
    end

    if params[:q] && !params[:q].blank?
      query = query.full_search(params[:q])
    end

    query
  end

  def self.event_types
    types = [:project_amended]
    types.push(:question_answered) if GlobalConfig.instance[:questions_enabled]
    types.push(:vendor_bid_awarded, :vendor_bid_unawarded, :vendor_bid_dismissed, :vendor_bid_undismissed) if GlobalConfig.instance[:bid_submission_enabled]
    Event.event_types.only(*types)
  end

  def display_name
    !name.blank? ? name : user.email
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

  def default_notification_preferences
    Vendor.event_types.values
  end

  private
  def touch_all_bids!
    bids.update_all(updated_at: Time.now)
  end
end
