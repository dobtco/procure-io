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
#

class Bid < ActiveRecord::Base
  include WatchableByUser

  belongs_to :project
  belongs_to :vendor
  belongs_to :dismissed_by_officer, foreign_key: "dismissed_by_officer_id"
  belongs_to :awarded_by_officer, foreign_key: "awarded_by_officer_id"

  has_many :bid_responses, dependent: :destroy, after_add: :force_index, after_remove: :force_index
  has_many :bid_reviews, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy, after_add: :force_index, after_remove: :force_index

  has_many :events, as: :targetable

  has_and_belongs_to_many :labels, after_add: :force_index, after_remove: :force_index

  searchable do
    text :vendor_name do vendor.name end
    text :vendor_email do vendor.email end

    text :body do
      bid_responses.map { |bid_response| bid_response.value }
    end

    boolean :submitted
    boolean :dismissed
    boolean :awarded

    integer :total_stars
    integer :total_comments

    dynamic_string :bid_responses do
      bid_responses.inject({}) do |hash, bid_response|
        hash["b#{bid_response.response_field_id.to_s}"] = bid_response.value
        hash
      end
    end

    time :created_at

    text :comments do
      comments.map { |comment| comment.body }
    end

    string :labels, multiple: true do
      labels.map { |label| label.name }
    end
  end

  def force_index(label)
    self.solr_index!
  end

  def submit
    self.submitted_at = Time.now
  end

  def submitted?
    self.submitted_at ? true : false
  end

  alias_method :submitted, :submitted?

  def dismissed?
    self.dismissed_at ? true : false
  end

  alias_method :dismissed, :dismissed?

  def awarded?
    self.awarded_at ? true : false
  end

  alias_method :awarded, :awarded?

  def dismiss_by_officer(officer)
    return false if self.dismissed_at
    self.dismissed_at = Time.now
    self.dismissed_by_officer_id = officer.id

    comments.create(officer_id: officer.id,
                    comment_type: "BidDismissed")
  end

  def dismiss_by_officer!(officer)
    self.dismiss_by_officer(officer)
    self.save

    self.delay.create_bid_dismissed_events!(officer)
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

  def award_by_officer!(officer)
    self.award_by_officer(officer)
    self.save
  end

  def undismiss_by_officer(officer)
    return false if !self.dismissed_at

    self.dismissed_at = nil
    self.dismissed_by_officer_id = nil

    comments.create(officer_id: officer.id,
                    comment_type: "BidUndismissed")

    self.delay.create_bid_undismissed_events!(officer)
  end

  def undismiss_by_officer!(officer)
    self.undismiss_by_officer(officer)
    self.save
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

  def unaward_by_officer!(officer)
    self.unaward_by_officer(officer)
    self.save
  end

  def bid_review_for_officer(officer)
    bid_reviews.where(officer_id: officer.id).first_or_initialize
  end

  def new_bid_review_for_officer(officer)
    bid_reviews.build(officer_id: officer.id)
  end

  def calculate_total_stars!
    self.total_stars = bid_reviews.where(starred: true).count
    self.save
  end

  def calculate_total_comments!
    self.total_comments = comments.count
    self.save
  end

  def valid_bid?
    bid_errors.empty? ? true : false
  end

  def bid_errors
    project.validate_bid(self)
  end

  private
  def create_bid_awarded_events!(officer)
    event = events.create(event_type: Event.event_types[:bid_awarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)

    project.watches.where(user_type: "Officer").where("user_id != ?", officer.id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id, user_type: "Officer")
    end

    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_awarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: self.vendor.id, user_type: "Vendor")
  end

  def create_bid_unawarded_events!(officer)
    event = events.create(event_type: Event.event_types[:bid_unawarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)

    project.watches.where(user_type: "Officer").where("user_id != ?", officer.id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.user_id, user_type: "Officer")
    end

    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_unawarded], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: self.vendor.id, user_type: "Vendor")

  end

  def create_bid_dismissed_events!(officer)
    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_dismissed], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: self.vendor.id, user_type: "Vendor")
  end

  def create_bid_undismissed_events!(officer)
    vendor_event = events.create(event_type: Event.event_types[:vendor_bid_undismissed], data: {bid: BidSerializer.new(self, root: false), officer: OfficerSerializer.new(officer, root: false)}.to_json)
    EventFeed.create(event_id: vendor_event.id, user_id: self.vendor.id, user_type: "Vendor")
  end
end
