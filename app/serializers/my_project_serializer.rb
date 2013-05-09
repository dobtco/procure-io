class MyProjectSerializer < ActiveModel::Serializer
  # cached true

  attributes :id, :title, :bids_due_at, :posted_at, :status_badge_class, :status_text, :bids_count

  def bids_count
    object.bids.submitted.count
  end

  def cache_key
    [object.cache_key, 'v1']
  end
end
