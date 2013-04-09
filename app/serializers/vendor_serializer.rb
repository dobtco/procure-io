class VendorSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :display_name

  has_one :vendor_profile
end
