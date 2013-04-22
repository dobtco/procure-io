class SimpleProjectSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at, :review_mode

  has_many :tags

  def abstract
    object.abstract_or_truncated_body
  end

  def review_mode
    Project.review_modes[object.review_mode]
  end

  def cache_key
    [object.cache_key, 'v2']
  end
end
