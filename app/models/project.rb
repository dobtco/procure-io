# == Schema Information
#
# Table name: projects
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  body                      :text
#  bids_due_at               :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  posted_at                 :datetime
#  posted_by_officer_id      :integer
#  total_comments            :integer          default(0), not null
#  has_unsynced_body_changes :boolean
#

class Project < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PostableByOfficer
  include WatchableByUser

  has_many :bids
  has_many :collaborators, order: 'created_at'
  has_many :officers, through: :collaborators, uniq: true, select: 'officers.*, collaborators.owner as owner',
                      order: 'created_at'
  has_many :questions, dependent: :destroy
  has_many :response_fields, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :amendments, dependent: :destroy

  has_many :events, as: :targetable

  has_and_belongs_to_many :tags

  searchable do
    text :title, default_boost: 2
    text :body

    boolean :posted
    time :bids_due_at
    time :posted_at

    text :tags_text do
      tags.map { |tag| tag.name }
    end

    string :tags, multiple: true do
      tags.map { |tag| tag.name }
    end

    text :amendments do
      amendments.posted.map { |amendment| amendment.body }
    end
  end

  handle_asynchronously :solr_index
  handle_asynchronously :remove_from_index

  def self.search_by_params(params, pagination_info = false)
    Project.search(:include => [:tags]) do
      with(:posted, true)

      fulltext(params[:q]) if params[:q] && !params[:q].blank?

      if params[:category] && !params[:category].blank?
        with(:tags).any_of([params[:category]])
      end

      if params[:posted_after]
        with(:posted_at).greater_than params[:posted_after]
      end

      if params[:sort] == "bidsDue"
        order_by(:bids_due_at, params[:direction] == 'asc' ? :asc : :desc)
      elsif params[:sort] == "postedAt" || !params[:sort]
        order_by(:posted_at, params[:direction] == 'asc' ? :asc : :desc)
      end

      if pagination_info
        paginate(page: pagination_info[:page], per_page: pagination_info[:per_page])
      else
        paginate(page: 1, per_page: 50)
      end
    end
  end

  def abstract
    truncate(self.body, length: 130, omission: "...")
  end

  def unanswered_questions
    questions.where("answer_body = '' OR answer_body IS NULL")
  end

  def owner
    officers.where(collaborators: {owner: true}).first
  end

  def owner_id
    owner ? owner.id : nil
  end

  def key_fields
    if response_fields.where(key_field: true).any?
      response_fields.where(key_field: true)
    else
      response_fields.limit(2)
    end
  end

  def unread_bids_for_officer(officer)
    submitted_bids.joins("LEFT JOIN bid_reviews on bid_reviews.bid_id = bids.id AND bid_reviews.officer_id = #{officer.id}")
                  .where("bid_reviews.read = false OR bid_reviews.read IS NULL")
  end

  def submitted_bids
    bids.where("submitted_at IS NOT NULL")
  end

  def dismissed_bids
    bids.where("dismissed_at IS NOT NULL")
  end

  def awarded_bids
    bids.where("awarded_at IS NOT NULL")
  end

  def calculate_total_comments!
    self.total_comments = comments.count
    self.save
  end

  def validate_bid(bid)
    errors = []

    response_fields.each do |response_field|
      response = bid.bid_responses.where(response_field_id: response_field.id).first
      value = response ? response.value : nil

      if response_field.field_options[:required] && (!value || value.blank?)
        errors << "#{response_field.label} is a required field."
      end

      if response_field.field_options[:minlength] && (!value || value.length < response_field.field_options[:minlength].to_i)
        errors << "#{response_field.label} is too short. It should be #{response_field.field_options[:minlength]} characters or more."
      end

      if response_field.field_options[:maxlength] && (!value || value.length > response_field.field_options[:maxlength].to_i)
        errors << "#{response_field.label} is too long. It should be #{response_field.field_options[:maxlength]} characters or less."
      end
    end

    errors
  end

  private
  def after_post_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "ProjectPosted")
  end

  def after_unpost_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "ProjectUnposted")
  end
end
