class CollaboratorSerializer < ActiveModel::Serializer
  attributes :id, :owner

  has_one :officer
end
