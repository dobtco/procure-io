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

  has_many :bids, dependent: :destroy
  has_many :questions
  has_many :saved_searches, dependent: :destroy

  has_many :watches, as: :user

  has_one :vendor_profile, dependent: :destroy
  has_many :responses, through: :vendor_profile

  pg_search_scope :full_search, against: [:name],
                                associated_against: { responses: [:value], user: [:email] },
                                using: { tsearch: { prefix: true } }

  def self.search_by_params(params, count_only = false)
    return_object = { meta: {} }
    return_object[:meta][:page] = [params[:page].to_i, 1].max
    return_object[:meta][:per_page] = 10 # [params[:per_page].to_i, 10].max

    # query = Vendor.joins("LEFT JOIN vendor_profiles ON vendor_profiles.vendor_id = vendor.id")
    query = Vendor.joins(:user).joins("LEFT JOIN vendor_profiles ON vendor_profiles.vendor_id = vendors.id")

    if params[:sort].to_i > 0
      cast_int = ResponseField.find(params[:sort]).field_type.in?(ResponseField::SORTABLE_VALUE_INTEGER_FIELDS)
      query = query.joins(sanitize_sql_array(["LEFT JOIN responses ON responses.responsable_id = vendor_profiles.id
                                               AND responses.responsable_type = 'VendorProfile'
                                               AND responses.response_field_id = ?", params[:sort]]))
                   .order("CASE WHEN responses.response_field_id IS NULL then 1 else 0 end,
                           responses.sortable_value#{cast_int ? '::numeric' : ''} #{params[:direction] == 'asc' ? 'asc' : 'desc' }")

    elsif params[:sort] == "email"
      query = query.order("users.email #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
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
end
