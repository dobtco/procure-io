class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at

  has_many :tags
end
