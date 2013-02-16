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
#

class Project < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  attr_accessible :bids_due_at, :body, :title, :posted_at, :posted_by_officer_id

  has_many :bids
  has_many :collaborators, order: 'created_at'
  has_many :officers, through: :collaborators, uniq: true, select: 'officers.*, collaborators.owner as owner',
                      order: 'created_at'
  has_many :questions
  has_many :response_fields

  belongs_to :posted_by_officer, foreign_key: "posted_by_officer_id"

  has_and_belongs_to_many :tags

  def posted?
    self.posted_at ? true : false
  end

  def post_by_officer(officer)
    return false if self.posted_at
    self.posted_at = Time.now
    self.posted_by_officer_id = officer.id
  end

  def post_by_officer!(officer)
    self.post_by_officer(officer)
    self.save
  end

  def unpost
    self.posted_at = nil
    self.posted_by_officer_id = nil
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

  def self.posted
    where("posted_at IS NOT NULL")
  end
end
