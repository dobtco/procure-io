class UserSerializer < ActiveModel::Serializer
  attributes :email, :gravatar_url
end
