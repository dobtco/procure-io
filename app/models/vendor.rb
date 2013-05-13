# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Vendor < ActiveRecord::Base
  include SharedUserMethods

  has_many :bids, dependent: :destroy
  has_many :questions
  has_many :saved_searches, dependent: :destroy

  has_many :watches, as: :user

  has_one :vendor_profile, dependent: :destroy
  has_many :responses, through: :vendor_profile

  has_searcher starting_query: Vendor.joins("INNER JOIN users ON users.owner_id = vendors.id AND users.owner_type = 'Vendor'").joins("LEFT JOIN vendor_profiles ON vendor_profiles.vendor_id = vendors.id")

  scope :join_response_for_response_field_id, -> (response_field_id) {
    joins(sanitize_sql_array(["LEFT JOIN responses ON responses.responsable_id = vendor_profiles.id
                               AND responses.responsable_type = 'VendorProfile'
                               AND responses.response_field_id = ?", response_field_id]))
  }

  pg_search_scope :full_search, against: [:name],
                                associated_against: { responses: [:value], user: [:email] },
                                using: { tsearch: { prefix: true } }

  after_update do
    bids.update_all(updated_at: Time.now)
  end

  def self.add_params_to_query(query, params, args = {})
    if params[:q] && !params[:q].blank?
      query = query.full_search(params[:q])
    end

    if params[:sort].to_i > 0
      cast_int = ResponseField.find(params[:sort]).field_type.in?(ResponseField::SORTABLE_VALUE_INTEGER_FIELDS)
      query = query.join_response_for_response_field_id(params[:sort])
                   .order("CASE WHEN responses.response_field_id IS NULL then 1 else 0 end,
                           responses.sortable_value#{cast_int ? '::numeric' : ''} #{params[:direction] == 'asc' ? 'asc' : 'desc' }")

    elsif params[:sort] == "email"
      query = query.order("lower(users.email) #{params[:direction] == 'asc' ? 'asc' : 'desc' }")
    elsif params[:sort] == "name" || params[:sort].blank?
      query = query.order("NULLIF(lower(name), '') #{params[:direction] == 'asc' ? 'asc NULLS LAST' : 'desc' }")
    end

    query
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

  def default_notification_preferences
    Vendor.event_types.values
  end
end
