class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at, :key_fields, :bids_due_at_readable, :posted_at_readable,
             :bids_due_at_readable_dateonly, :posted_at_readable_dateonly

  has_many :tags
  has_many :labels

  def bids_due_at_readable
    object.bids_due_at.to_formatted_s(:readable)
  end

  def posted_at_readable
    object.posted_at.to_formatted_s(:readable)
  end

  def bids_due_at_readable_dateonly
    object.bids_due_at.to_formatted_s(:readable_dateonly)
  end

  def posted_at_readable_dateonly
    object.posted_at.to_formatted_s(:readable_dateonly)
  end
end
