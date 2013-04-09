class VendorSerializer < ActiveModel::Serializer
  attributes :id, :email, :name

  has_one :vendor_profile
end
