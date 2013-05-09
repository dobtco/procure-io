class SimpleProjectSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at, :review_mode, :status_badge_class, :status_text

  has_many :tags

  def abstract
    object.abstract_or_truncated_body
  end

  def review_mode
    Project.review_modes[object.review_mode]
  end

  def cache_key
    [object.cache_key, 'v3']
  end
end
