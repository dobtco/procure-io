class VendorSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :display_name
end
