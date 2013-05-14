# == Schema Information
#
# Table name: bids
#
#  id                               :integer          not null, primary key
#  vendor_id                        :integer
#  project_id                       :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  submitted_at                     :datetime
#  dismissed_at                     :datetime
#  dismissed_by_officer_id          :integer
#  total_stars                      :integer          default(0), not null
#  total_comments                   :integer          default(0), not null
#  awarded_at                       :datetime
#  awarded_by_officer_id            :integer
#  average_rating                   :decimal(3, 2)
#  total_ratings                    :integer
#  bidder_name                      :string(255)
#  dismissal_message                :text
#  show_dismissal_message_to_vendor :boolean          default(FALSE)
#  award_message                    :text
#

class Bid < ActiveRecord::Base
  include SerializationHelper

  include Behaviors::AwardableAndDismissableByOfficer
  include Behaviors::Responsable
  include Behaviors::Submittable
  include Behaviors::TargetableForEvents
  include Behaviors::WatchableByUser

  self.cache_timestamp_format = :nsec

  belongs_to :project
  belongs_to :vendor
  has_one :user, through: :vendor
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

  scope :join_my_bid_review, -> (officer_id) {
    select('bids.*,
            bid_reviews.starred as starred,
            bid_reviews.read as read,
            bid_reviews.rating as rating')
    .joins(sanitize_sql_array(["LEFT JOIN bid_reviews ON bid_reviews.bid_id = bids.id
                                                      AND bid_reviews.officer_id = ?", officer_id]))
  }

  has_searcher

  pg_search_scope :full_search,
                  associated_against: { responses: [:value],
                                        vendor: [:name],
                                        user: [:email],
                                        comments: [:body],
                                        labels: [:name] },
                  using: { tsearch: { prefix: true } }

  calculator :total_stars do bid_reviews.where(starred: true) end
  calculator :total_ratings do bid_reviews.that_have_ratings end
  calculator :total_comments do comments.not_auto_generated end
  calculator :average_rating do bid_reviews.that_have_ratings.average(:rating) end

  def self.add_params_to_query(query, params, args = {})
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

  calculator :bidder_name do
    if vendor
      nil
    elsif project && project.key_fields.any?
      key_field_responses.map { |r| r.display_value }.join(" ")
    else
      "#{I18n.t('g.vendor')} ##{id}"
    end
  end

  def bidder_name
    vendor ? vendor.display_name : read_attribute(:bidder_name)
  end

  def bid_review_for_officer(officer)
    bid_reviews.where(officer_id: officer.id).first_or_initialize
  end

  def responsable_validator
    @responsable_validator ||= ResponsableValidator.new(project.response_fields, responses)
  end

  def status
    if !submitted?
      'draft_saved'
    else
      awarded_dismissed_or_open_status
    end
  end

  def text_status
    I18n.t("g.#{status}")
  end

  def badged_text_status
    badge_class = case status
    when 'awarded'
      "badge-success"
    when 'dismissed'
      "badge-important"
    when 'open'
      "badge-info"
    when 'draft_saved'
      ""
    end

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
  def after_dismiss_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "BidDismissed")

    delay.create_events(:vendor_bid_dismissed, vendor.user, self, project, officer) if vendor
  end

  def after_award_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "BidAwarded")

    project.comments.create(officer_id: officer.id,
                            comment_type: "ProjectBidAwarded",
                            data: BidForCommentSerializer.new(self, root: false).to_json)

    delay.create_events(:bid_awarded, project.active_watchers(:officer, not_users: officer.user), self, project, officer)
    delay.create_events(:vendor_bid_awarded, vendor.user, self, project, officer) if vendor
  end

  def after_undismiss_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "BidUndismissed")

    delay.create_events(:vendor_bid_undismissed, vendor.user, self, project, officer) if vendor
  end

  def after_unaward_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "BidUnawarded")

    project.comments.create(officer_id: officer.id,
                            comment_type: "ProjectBidUnawarded",
                            data: BidForCommentSerializer.new(self, root: false).to_json)

    delay.create_events(:bid_unawarded, project.active_watchers(:officer, not_users: officer.user), self, project, officer)
    delay.create_events(:vendor_bid_unawarded, vendor.user, self, project, officer) if vendor
  end

  def after_submit
    delay.create_events(:bid_submitted, project.active_watchers(:officer), self, project)
  end

  def calculate_project_total_submitted_bids_if_submitted_at_changed!
    return unless submitted_at_changed?
    calculate_project_total_submitted_bids!
  end

  def calculate_project_total_submitted_bids!
    project.calculate_total_submitted_bids!
  end
end
