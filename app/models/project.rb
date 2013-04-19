# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  body                 :text
#  bids_due_at          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  posted_at            :datetime
#  posted_by_officer_id :integer
#  total_comments       :integer          default(0), not null
#  form_options         :text
#  abstract             :string(255)
#  featured             :boolean
#  review_mode          :integer          default(1)
#

require_dependency 'enum'

class Project < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PostableByOfficer
  include WatchableByUser
  include PgSearch
  include Searcher

  attr_accessor :updating_officer_id

  is_impressionable

  has_many :bids
  has_many :collaborators, order: 'created_at', dependent: :destroy
  has_many :officers, through: :collaborators, uniq: true, select: 'officers.*, collaborators.owner as owner',
                      order: 'created_at'
  has_many :questions, dependent: :destroy
  has_many :response_fields, as: :response_fieldable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :amendments, dependent: :destroy

  has_many :events, as: :targetable

  has_many :project_revisions, dependent: :destroy, order: 'created_at DESC'

  after_update :generate_project_revisions_if_body_changed!

  has_and_belongs_to_many :tags

  serialize :form_options, Hash

  scope :featured, where(featured: true)
  scope :open_for_bids, where("bids_due_at IS NULL OR bids_due_at > ?", Time.now)

  pg_search_scope :full_search, against: [:title, :body],
                                associated_against: { amendments: [:title, :body],
                                                      questions: [:body, :answer_body],
                                                      tags: [:name] },
                                using: {
                                  tsearch: {prefix: true}
                                }

  has_searcher starting_query: Project.open_for_bids.posted

  def self.review_modes
    @review_modes ||= Enum.new(:stars, :one_through_five)
  end

  def self.add_params_to_query(query, params)
    if !params[:q].blank?
      query = query.full_search(params[:q])
    end

    if !params[:category].blank?
      query = query.joins("LEFT JOIN projects_tags ON projects.id = projects_tags.project_id INNER JOIN tags ON tags.id = projects_tags.tag_id")
                   .where("tags.name = ?", params[:category])
    end

    if params[:posted_after]
      query = query.where(posted_at: params[:posted_after]..Time.now)
    end

    if !params[:sort] || !params[:sort].in?(["posted_at", "bids_due_at"])
      params[:sort] = "posted_at"
    end

    query = query.order("#{params[:sort]} #{params[:direction] == 'asc' ? 'asc' : 'desc'}")

    query
  end

  def abstract_or_truncated_body
    !read_attribute(:abstract).blank? ? read_attribute(:abstract) : truncate(self.body, length: 130, omission: "...")
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
      []
    end
  end

  def unread_bids_for_officer(officer)
    bids.submitted.joins("LEFT JOIN bid_reviews on bid_reviews.bid_id = bids.id AND bid_reviews.officer_id = #{officer.id}")
                  .where("bid_reviews.read = false OR bid_reviews.read IS NULL")
  end

  def calculate_total_comments!
    self.total_comments = comments.count
    self.save
  end

  def create_bid_from_hash!(params, label_to_apply = nil)
    raise "Required parameters not included." if !params["email"] || params["email"].blank?

    if (user = User.where(email: params["email"], owner_type: "Officer").first)
      vendor = user.owner
    else
      vendor = Vendor.create(name: params["name"], account_disabled: true)
      user = User.where(email: params["email"]).first || vendor.create_user(email: params["email"])
    end

    bid = vendor.bids.create(project_id: self.id)

    self.response_fields.each do |response_field|
      if (val = params[response_field.label.downcase])
        bid.responses.create(response_field_id: response_field.id, value: val)
      end
    end

    bid.submitted_at = Time.now
    bid.save
    bid.labels << label_to_apply if label_to_apply
  end

  def open_for_bids?
    !bids_due_at || (bids_due_at > Time.now)
  end

  def bid_confirmation_message
    if !form_options["form_confirmation_message"].blank?
      form_options["form_confirmation_message"]
    else
      I18n.t('g.bid_confirmation_message')
    end
  end

  private
  def after_post_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "ProjectPosted")

    GlobalConfig.instance.delay.run_event_hooks_for_project!(self)
  end

  def after_unpost_by_officer(officer)
    comments.create(officer_id: officer.id,
                    comment_type: "ProjectUnposted")
  end

  def generate_project_revisions_if_body_changed!
    return unless body_changed?
    project_revisions.create(body: body_was, saved_by_officer_id: updating_officer_id)
  end
end
