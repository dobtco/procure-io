class SimpleProjectSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at, :bids_due_at_readable, :posted_at_readable,
             :bids_due_at_readable_dateonly, :posted_at_readable_dateonly, :review_mode

  has_many :tags

  def abstract
    object.abstract_or_truncated_body
  end

  def review_mode
    Project.review_modes[object.review_mode]
  end

  def bids_due_at_readable
    object.bids_due_at.to_formatted_s(:readable) if object.bids_due_at
  end

  def posted_at_readable
    object.posted_at.to_formatted_s(:readable) if object.posted_at
  end

  def bids_due_at_readable_dateonly
    object.bids_due_at.to_formatted_s(:readable_dateonly) if object.bids_due_at
  end

  def posted_at_readable_dateonly
    object.posted_at.to_formatted_s(:readable_dateonly) if object.posted_at
  end

  def cache_key
    [object.cache_key, 'v1']
  end
end
