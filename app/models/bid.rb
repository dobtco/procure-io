# == Schema Information
#
# Table name: bids
#
#  id                      :integer          not null, primary key
#  vendor_id               :integer
#  project_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  submitted_at            :datetime
#  dismissed_at            :datetime
#  dismissed_by_officer_id :integer
#  total_stars             :integer          default(0), not null
#  total_comments          :integer          default(0), not null
#  awarded_at              :datetime
#  awarded_by_officer_id   :integer
#  average_rating          :decimal(3, 2)
#  total_ratings           :integer
#

class Bid < ActiveRecord::Base
  include WatchableByUser
  include PgSearch
  include IsResponsable
  include Searcher

  belongs_to :project
  belongs_to :vendor
  has_one :user, through: :vendor
  belongs_to :dismissed_by_officer, foreign_key: "dismissed_by_officer_id"
  belongs_to :awarded_by_officer, foreign_key: "awarded_by_officer_id"

  has_many :bid_reviews, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :events, as: :targetable

  has_and_belongs_to_many :labels, after_add: :update_timestamp, after_remove: :update_timestamp

  scope :submitted, where("submitted_at IS NOT NULL")
  scope :dismissed, where("dismissed_at IS NOT NULL")
  scope :awarded, where("awarded_at IS NOT NULL")
  scope :where_open, where("dismissed_at IS NULL AND awarded_at IS NULL")
  scope :starred, where("total_stars > 0")
  scope :join_labels, joins("LEFT JOIN bids_labels ON bids.id = bids_labels.bid_id LEFT JOIN labels ON labels.id = bids_labels.label_id")
  scope :join_responses_for_response_field_id, lambda { |response_field_id|
    joins sanitize_sql_array(["LEFT JOIN responses ON responses.responsable_id = bids.id
                                                   AND responses.responsable_type = 'Bid'
                                                   AND responses.response_field_id = ?", response_field_id])
  }

  pg_search_scope :full_search, associated_against: { responses: [:value],
                                                      vendor: [:name],
                                                      user: [:email],
                                                      comments: [:body],
                                                      labels: [:name] },
                                using: { tsearch: { prefix: true } }

  has_searcher

  def self.add_params_to_query(query, params)
    if params[:f2] == "dismissed"
      query = query.dismissed
    elsif params[:f2] == "awarded"
      query = query.awarded
    else
      query = query.where_open
    end

    if params[:f1] == "starred"
      query = query.starred
    end

    if !params[:label].blank?
      query = query.join_labels.where("labels.name = ?", params[:label])
    end

    direction = params[:direction] == 'asc' ? 'asc' : 'desc'

    if params[:sort].to_i > 0
      cast_int = ResponseField.find(params[:sort]).field_type.in?(ResponseField::SORTABLE_VALUE_INTEGER_FIELDS)
      query = query.join_responses_for_response_field_id(params[:sort])
                   .order("CASE WHEN responses.response_field_id IS NULL then 1 else 0 end,
                           responses.sortable_value#{cast_int ? '::numeric' : ''} #{direction}")
    elsif params[:sort] == "stars"
      query = query.order("total_stars #{direction}")
    elsif params[:sort] == "average_rating"
      query = query.order("case when average_rating is null then 1 else 0 end, average_rating #{direction}")
    elsif params[:sort] == "created_at"
      query = query.order("bids.created_at #{direction}")
    elsif params[:sort] == "name" || params[:sort].blank?
      query = query.order("vendors.name #{direction}")
    end

    if !params[:q].blank?
      query = query.full_search(params[:q])
    end

    query
  end

  def self.search_meta_info(params, args = {})
    counts = {
      all: self.searcher(params.merge(f1: "open"), args.merge(count_only: true)),
      starred: self.searcher(params.merge({f1: "starred"}), args.merge(count_only: true)),
      open: self.searcher(params.merge({f2: "open"}), args.merge(count_only: true)),
      dismissed: self.searcher(params.merge({f2: "dismissed"}), args.merge(count_only: true)),
      awarded: self.searcher(params.merge({f2: "awarded"}), args.merge(count_only: true))
    }

    args[:project].labels.each do |label|
      counts[label.id] = self.searcher(params.merge({label: label.name}), args.merge(count_only: true))
    end

    { counts: counts }
  end

  def submit
    self.submitted_at = Time.now
    self.delay.create_bid_submitted_events!
  end

  def submitted
    self.submitted_at ? true : false
  end

  def dismissed
    self.dismissed_at ? true : false
  end

  def awarded
    self.awarded_at ? true : false
  end

  def dismiss_by_officer(officer)
    return false if self.dismissed_at
    self.dismissed_at = Time.now
    self.dismissed_by_officer_id = officer.id

    comments.create(officer_id: officer.id,
                    comment_type: "BidDismissed")
  end

  def award_by_officer(officer)
    return false if self.awarded_at
    self.awarded_at = Time.now
    self.awarded_by_officer_id = officer.id

    comments.create(officer_id: officer.id,
                    comment_type: "BidAwarded")

    project.comments.create(officer_id: officer.id,
                            comment_type: "ProjectBidAwarded",
                            data: BidForCommentSerializer.new(self, root: false).to_json)

    self.delay.create_bid_awarded_events!(officer)
  end

  def undismiss_by_officer(officer)
    return false if !self.dismissed_at

    self.dismissed_at = nil
    self.dismissed_by_officer_id = nil

    comments.create(officer_id: officer.id,
                    comment_type: "BidUndismissed")

    self.delay.create_bid_undismissed_events!(officer)
  end

  def unaward_by_officer(officer)
    return false if !self.awarded_at

    self.awarded_at = nil
    self.awarded_by_officer_id = nil

    comments.create(officer_id: officer.id,
                    comment_type: "BidUnawarded")

    project.comments.create(officer_id: officer.id,
                            comment_type: "ProjectBidUnawarded",
                            data: BidForCommentSerializer.new(self, root: false).to_json)

    self.delay.create_bid_unawarded_events!(officer)
  end

  def bid_review_for_officer(officer)
    bid_reviews.where(officer_id: officer.id).first_or_initialize
  end

  def new_bid_review_for_officer(officer)
    bid_reviews.build(officer_id: officer.id)
  end

  def calculate_total_stars
    self.total_stars = bid_reviews.where(starred: true).count
  end

  def calculate_total_ratings
    self.total_ratings = bid_reviews.that_have_ratings.count
  end

  def calculate_total_comments
    self.total_comments = comments.count
  end

  def calculate_average_rating
    self.average_rating = bid_reviews.that_have_ratings.average(:rating)
  end

  def text_status
    if dismissed_at
      "Dismissed"
    elsif awarded_at
      "Awarded"
    else
      "Open"
    end
  end

  def responsable_validator
    @responsable_validator ||= ResponsableValidator.new(project.response_fields, responses)
  end

  dangerous_alias :unaward_by_officer, :undismiss_by_officer, :award_by_officer, :dismiss_by_officer,
                  :calculate_total_stars, :calculate_total_ratings, :calculate_total_comments,
                  :calculate_average_rating

  question_alias :submitted, :dismissed, :awarded

  private
  def update_timestamp(*args)
    self.touch
  end

  def create_bid_submitted_events!
    event = events.create(event_type: Event.event_types[:bid_submitted], data: {bid: BidSerializer.new(self, root: false)}.to_json)

    project.watches.not_disabled.where_user_is_officer.each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end
  end

  def create_bid_awarded_events!(officer)
    event = events.create(event_type: Event.event_types[:bid_awarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)

    project.watches.not_disabled.where_user_is_officer.where("user_id != ?", officer.user.id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end

    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_awarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: vendor.user.id)
  end

  def create_bid_unawarded_events!(officer)
    event = events.create(event_type: Event.event_types[:bid_unawarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)

    project.watches.not_disabled.where_user_is_officer.where("user_id != ?", officer.user.id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id)
    end

    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_unawarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: vendor.user.id)

  end

  def create_bid_dismissed_events!(officer)
    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_dismissed], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: vendor.user.id)
  end

  def create_bid_undismissed_events!(officer)
    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_undismissed], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: vendor.user.id)
  end
end
