# == Schema Information
#
# Table name: bids
#
#  id                               :integer          not null, primary key
#  vendor_id                        :integer
#  project_id                       :integer
#  submitted_at                     :datetime
#  dismissed_at                     :datetime
#  dismisser_id                     :integer
#  total_stars                      :integer          default(0)
#  total_comments                   :integer          default(0)
#  awarded_at                       :datetime
#  awarder_id                       :integer
#  average_rating                   :decimal(3, 2)
#  total_ratings                    :integer          default(0)
#  bidder_name                      :string(255)
#  dismissal_message                :text
#  show_dismissal_message_to_vendor :boolean          default(FALSE)
#  award_message                    :text
#  created_at                       :datetime
#  updated_at                       :datetime
#

class Bid < ActiveRecord::Base
  include SerializationHelper

  include Behaviors::AwardableAndDismissable
  include Behaviors::Responsable
  include Behaviors::Submittable
  include Behaviors::TargetableForEvents
  include Behaviors::Watchable

  self.cache_timestamp_format = :nsec

  belongs_to :project
  belongs_to :vendor
  has_many :bid_reviews, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_and_belongs_to_many :labels, after_add: :touch_self, after_remove: :touch_self

  before_save :calculate_bidder_name
  after_save :calculate_project_total_submitted_bids_if_submitted_at_changed!
  after_destroy :calculate_project_total_submitted_bids!

  scope :starred, -> { where("total_stars > 0") }
  scope :join_labels, -> { joins("LEFT JOIN bids_labels ON bids.id = bids_labels.bid_id LEFT JOIN labels ON labels.id = bids_labels.label_id") }

  scope :join_responses_for_response_field_id, -> (response_field_id) {
    joins sanitize_sql_array(["LEFT JOIN responses ON responses.responsable_id = bids.id
                                                   AND responses.responsable_type = 'Bid'
                                                   AND responses.response_field_id = ?", response_field_id])
  }

  scope :join_my_watches, -> (user_id) {
    select('bids.*, CASE WHEN my_watch.id IS NULL THEN false else true END as i_am_watching')
    .joins(sanitize_sql_array(["LEFT JOIN watches as my_watch ON my_watch.watchable_type = 'Bid'
                                                             AND my_watch.watchable_id = bids.id
                                                             AND my_watch.user_id = ?", user_id]))
  }

  scope :unread, -> {
    where("read IS NULL or read = FALSE")
  }

  scope :join_my_bid_review, -> (user_id) {
    select('bids.*,
            bid_reviews.starred as starred,
            bid_reviews.read as read,
            bid_reviews.rating as rating')
    .joins(sanitize_sql_array(["LEFT JOIN bid_reviews ON bid_reviews.bid_id = bids.id
                                                      AND bid_reviews.user_id = ?", user_id]))
  }

  scope :join_project, -> {
    joins("LEFT JOIN projects ON bids.project_id = projects.id")
  }

  has_searcher

  pg_search_scope :full_search,
                  associated_against: { responses: [:value],
                                        vendor: [:name],
                                        comments: [:body],
                                        labels: [:name] },
                  using: { tsearch: { prefix: true } }

  pg_search_scope :full_search_vendor,
                  associated_against: { responses: [:value],
                                        project: [:title] },
                  using: { tsearch: { prefix: true } }

  calculator :total_stars do bid_reviews.where(starred: true) end
  calculator :total_ratings do bid_reviews.that_have_ratings end
  calculator :total_comments do comments end
  calculator :average_rating do bid_reviews.that_have_ratings.average(:rating) end

  calculator :bidder_name do
    if vendor
      nil
    elsif first_response && !first_response.display_value.blank?
      first_response.display_value
    else
      "#{I18n.t('g.vendor')} ##{id}"
    end
  end

  def identifier
    "##{self.id}"
  end

  def self.add_params_to_query(query, params, args = {})
    if args[:vendor_searching]
      if !params[:q].blank?
        query = query.full_search_vendor(params[:q])
      end

      direction = params[:direction] == 'desc' ? 'desc' : 'asc'


      if params[:sort] == "title"
        query = query.order("projects.title #{direction}")
      elsif params[:sort] == "bids_due_at"
        query = query.order("projects.bids_due_at #{direction}")
      elsif params[:sort] == "updated_at" || params[:sort].blank?
        query = query.order("COALESCE(bids.submitted_at, bids.updated_at) #{direction}") # updated_by_vendor_at
      end

    else
      if params[:status] == "dismissed"
        query = query.dismissed
      elsif params[:status] == "awarded"
        query = query.awarded
      else
        query = query.where_open
      end

      if !params[:label].blank?
        query = query.join_labels.where("labels.name = ?", params[:label])
      end

      direction = params[:direction] == 'desc' ? 'desc' : 'asc'

      if !params[:q].blank?
        query = query.full_search(params[:q])
      end

      if params[:sort].to_i > 0
        cast_int = ResponseField.find(params[:sort]).field_type.in?(ResponseField::SORTABLE_VALUE_INTEGER_FIELDS)
        query = query.join_responses_for_response_field_id(params[:sort])
                     .order("CASE WHEN responses.response_field_id IS NULL then 1 else 0 end,
                             responses.sortable_value#{cast_int ? '::numeric' : ''} #{direction}")
      elsif params[:sort] == "rating"
        if args[:project].review_mode == Project.review_modes[:stars]
          query = query.order("total_stars #{direction}")
        else # one_through_five
          query = query.order("case when average_rating is null then 1 else 0 end, average_rating #{direction}")
        end
      elsif params[:sort] == "created_at"
        query = query.order("bids.created_at #{direction}")
      elsif params[:sort] == "comments"
        query = query.order("bids.total_comments #{direction}")
      elsif params[:sort] == "name" || params[:sort].blank?
        query = query.order("COALESCE(vendors.name, bids.bidder_name) #{direction}, bids.created_at #{direction}")
      end
    end

    query
  end

  def self.search_meta_info(params, args = {})
    new_args = args.merge(count_only: true, starting_query: args[:simpler_query])

    counts = {
      open: self.searcher(params.merge({status: "open"}), new_args),
      dismissed: self.searcher(params.merge({status: "dismissed"}), new_args),
      awarded: self.searcher(params.merge({status: "awarded"}), new_args)
    }

    args[:project].labels.each do |label|
      counts[label.id] = self.searcher(params.merge({label: label.name}), new_args)
    end

    { counts: counts }
  end

  def first_response
    responses.joins(:response_field).order("response_fields.sort_order").first
  end

  def bidder_name
    vendor ? vendor.name : read_attribute(:bidder_name)
  end

  def bid_review_for_user(user)
    bid_reviews.where(user_id: user.id).first_or_initialize
  end

  def responsable_validator
    @responsable_validator ||= ResponsableValidator.new(project.response_fields, responses)
  end

  def status
    if !submitted?
      :draft_saved
    else
      awarded_dismissed_or_open_status
    end
  end

  def text_status
    I18n.t("g.#{status}")
  end

  def badge_class
    case status
    when :awarded
      "badge-success"
    when :dismissed
      "badge-important"
    when :open
      "badge-info"
    when :draft_saved
      ""
    end
  end

  def badged_text_status
    "<span class='badge #{badge_class}'>#{text_status}</span>"
  end

  def vendor_dismissal_message
    dismissal_message if show_dismissal_message_to_vendor
  end

  def updated_by_vendor_at
    if submitted?
      submitted_at
    else
      updated_at
    end
  end

  private
  def after_dismiss(user)
    create_events(:bid_dismissed,
                  project.active_watchers(not_users: user, user_can: :collaborate_on),
                  self,
                  project,
                  user)

    create_events(:your_bid_dismissed, vendor.users, self, project, user) unless !vendor
  end


  def after_award(user)
    create_events(:bid_awarded,
                  project.active_watchers(not_users: user, user_can: :collaborate_on),
                  self,
                  project,
                  user)

    create_events(:your_bid_awarded, vendor.users, self, project, user) unless !vendor
  end

  def after_undismiss(user)
    create_events(:bid_undismissed,
                  project.active_watchers(not_users: user, user_can: :collaborate_on),
                  self,
                  project,
                  user)


    create_events(:your_bid_undismissed, vendor.users, self, project, user) unless !vendor
  end

  def after_unaward(user)
    create_events(:bid_unawarded,
                  project.active_watchers(not_users: user, user_can: :collaborate_on),
                  self,
                  project,
                  user)

    create_events(:your_bid_unawarded, vendor.users, self, project, user) unless !vendor
  end

  def after_submit
    create_events(:bid_submitted, project.active_watchers(user_can: :collaborate_on), self, project)
  end

  [:after_dismiss, :after_award, :after_undismiss, :after_unaward, :after_submit].each do |x|
    handle_asynchronously x
  end

  def calculate_project_total_submitted_bids_if_submitted_at_changed!
    calculate_project_total_submitted_bids! if submitted_at_changed?
  end

  def calculate_project_total_submitted_bids!
    project.calculate_total_submitted_bids!
  end
end
