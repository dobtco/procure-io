class OfficerSerializer < ActiveModel::Serializer
  # cached true

  attributes :id, :name, :display_name, :created_at, :title, :updated_at, :me?, :is_admin_or_god, :role_name, :urls

  has_one :user

  def include_is_admin_or_god?
    me?
  end

  def me?
    scope && scope.owner == object
  end

  def cache_key
    [object.cache_key, scope ? scope.cache_key : 'no-scope', 'v6']
  end

  def role_name
    object.role.name
  end

  def urls
    ability = Ability.new(scope)
    urls = {}

    urls[:edit] = edit_officer_path(object) if ability.can?(:update, object)
    urls[:destroy] = officer_path(object) if ability.can?(:destroy, object)

    urls
  end

  def include_role_name?
    @options[:detailed]
  end

  def include_urls?
    @options[:detailed]
  end
end
