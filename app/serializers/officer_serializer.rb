class OfficerSerializer < ActiveModel::Serializer
  # cached true

  attributes :id, :name, :display_name, :created_at, :title, :updated_at, :me?, :is_admin_or_god, :role_name

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
end
