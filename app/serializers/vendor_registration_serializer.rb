class VendorRegistrationSerializer < ActiveModel::Serializer
  attributes :id, :status, :status_text, :badge_class, :submitted_at

  has_one :vendor
  has_one :registration
end
