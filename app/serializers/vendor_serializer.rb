class VendorSerializer < ActiveModel::Serializer
  attributes :id, :name, :urls

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
