class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at, :key_fields

  has_many :tags
  has_many :labels
end
