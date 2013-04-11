class UserSerializer < ActiveModel::Serializer
  attributes :id, :gravatar_url, :email
end
