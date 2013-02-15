class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :abstract, :body

  has_many :tags
end
