# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  body        :text
#  bids_due_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  posted      :boolean
#

class Project < ActiveRecord::Base
  attr_accessible :bids_due_at, :body, :title, :posted

  has_many :bids
  has_many :collaborators, order: 'created_at'
  has_many :officers, through: :collaborators, uniq: true, select: 'officers.*, collaborators.owner as owner',
                      order: 'created_at'
  has_many :questions
  has_many :response_fields

  def unanswered_questions
    questions.where("answer_body = '' OR answer_body IS NULL")
  end

  def owner
    officers.where(collaborators: {owner: true}).first
  end

  def owner_id
    owner ? owner.id : nil
  end

  def self.posted
    where(posted: true)
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
end
