class VendorSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :name, :display_name, :urls

  has_one :user
  has_one :vendor_profile

  def cache_key
    [object.cache_key, 'v3']
  end

  def urls
    ability = Ability.new(scope)
    urls = {}

    urls[:edit] = edit_vendor_path(object) if ability.can?(:update, object)
    urls[:destroy] = vendor_path(object) if ability.can?(:destroy, object)

    urls
  end

  def include_urls?
    @options[:detailed]
  end
end
