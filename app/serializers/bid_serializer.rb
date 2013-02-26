class BidSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :submitted_at, :dismissed_at, :dismissed_by_officer_id,
             :project_id, :total_comments, :total_stars, :awarded_at, :awarded_by_officer_id

  has_one :project
  has_one :vendor

  has_many :bid_responses
  has_many :labels
end
