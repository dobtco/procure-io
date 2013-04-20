class VendorSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :name, :display_name

  has_one :user
  has_one :vendor_profile

  def cache_key
    [object.cache_key, 'v1']
  end
end
