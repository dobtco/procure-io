class OfficerSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :created_at, :title, :updated_at, :gravatar_url
end
