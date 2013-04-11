class VendorSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_one :user
  has_one :vendor_profile
end
