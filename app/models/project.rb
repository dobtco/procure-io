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
#  form_description          :text
#  form_confirmation_message :text
#  abstract                  :string(255)
#

class Project < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PostableByOfficer
  include WatchableByUser
  include PgSearch

  attr_accessor :updating_officer_id

  has_many :bids
  has_many :collaborators, order: 'created_at', dependent: :destroy
  has_many :officers, through: :collaborators, uniq: true, select: 'officers.*, collaborators.owner as owner',
                      order: 'created_at'
  has_many :questions, dependent: :destroy
  has_many :response_fields, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :amendments, dependent: :destroy

  has_many :events, as: :targetable

  has_many :project_revisions, dependent: :destroy, order: 'created_at DESC'

  after_update :generate_project_revisions_if_body_changed!

  has_and_belongs_to_many :tags

  pg_search_scope :full_search, against: [:title, :body],
                                associated_against: { amendments: [:title, :body],
                                                      questions: [:body, :answer_body],
                                                      tags: [:name] },
                                using: {
                                  tsearch: {prefix: true}
                                }

  def self.search_by_params(params)
    return_object = { meta: {} }
    return_object[:meta][:page] = [params[:page].to_i, 1].max
    return_object[:meta][:per_page] = 10 # [params[:per_page].to_i, 10].max

    query = Project.posted

    if params[:q] && !params[:q].blank?
      query = query.full_search(params[:q])
    end

    if params[:category] && !params[:category].blank?
      query = query.joins("LEFT JOIN projects_tags ON projects.id = projects_tags.project_id INNER JOIN tags ON tags.id = projects_tags.tag_id")
                   .where("tags.name = ?", params[:category])
    end

    if params[:posted_after]
      query = query.where(posted_at: params[:posted_after]..Time.now)
    end

    return_object[:meta][:total] = query.count
    return_object[:meta][:last_page] = [(return_object[:meta][:total].to_f / return_object[:meta][:per_page]).ceil, 1].max
    return_object[:page] = [return_object[:meta][:last_page], return_object[:meta][:page]].min

    if !params[:sort] || !params[:sort].in?(["posted_at", "bids_due_at"])
      params[:sort] = "posted_at"
    end

    query = query.order("#{params[:sort]} #{(params[:direction] && (params[:direction] == 'asc')) ? 'asc' : 'desc'}")

    return_object[:results] = query.limit(return_object[:meta][:per_page])
                                   .offset((return_object[:meta][:page] - 1)*return_object[:meta][:per_page])

    return_object
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
      response_fields.limit(2)
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

    vendor = Vendor.where(email: params["email"])
                   .first_or_create(password: SecureRandom.urlsafe_base64, name: params["name"], account_disabled: true)

    bid = vendor.bids.create(project_id: self.id)

    self.response_fields.each do |response_field|
      if (val = params[response_field.label.downcase])
        bid.bid_responses.create(response_field_id: response_field.id, value: val)
      end
    end

    bid.submit
    bid.save
    bid.labels << label_to_apply if label_to_apply
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
