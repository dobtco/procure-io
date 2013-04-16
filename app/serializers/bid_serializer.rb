class BidSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :created_at, :updated_at, :submitted_at, :dismissed_at, :dismissed_by_officer_id,
             :project_id, :total_comments, :total_stars, :awarded_at, :awarded_by_officer_id,
             :submitted_at_readable, :average_rating, :total_ratings, :watching?

  has_one :project
  has_one :vendor

  has_many :responses
  has_many :labels

  def submitted_at_readable
    object.submitted_at.to_formatted_s(:readable) if object.submitted_at
  end

  def average_rating
    # round to 2 decimal places
    sprintf('%.2f', object.average_rating) if object.average_rating
  end

  def cache_key
    [object.cache_key, (scope ? scope.id : 0), 'v2']
  end

  def watching?
    scope && scope.watches?("Bid", object.id)
  end
end
