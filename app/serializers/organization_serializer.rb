class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :username, :name, :email
end