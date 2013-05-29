class VendorProfileSerializer < ActiveModel::Serializer
  attributes :id

  has_many :responses
end
