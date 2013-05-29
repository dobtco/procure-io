class UserSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :email, :gravatar_url
end
