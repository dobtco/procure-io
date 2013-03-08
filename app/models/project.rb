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

  def self.search_by_params(params)
    return_object = { meta: {} }
    return_object[:meta][:page] = [params[:page].to_i, 1].max
    return_object[:meta][:per_page] = 10 # [params[:per_page].to_i, 10].max

    query = self.posted

    # @todo fulltext stuff

    if params[:category] && !params[:category].blank?
      query = query.joins("LEFT JOIN projects_tags ON projects.id = projects_tags.project_id INNER JOIN tags ON tags.id = projects_tags.tag_id")
                   .where("tags.name = ?", params[:category])
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

  # @todo these should be scopes
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
