class VendorSerializer < ActiveModel::Serializer
  attributes :id, :name, :display_name

  has_one :user
  has_one :vendor_profile
end
