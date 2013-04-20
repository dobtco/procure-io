class OfficerSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :name, :display_name, :created_at, :title, :updated_at, :me?, :permission_level

  has_one :user

  def me?
    scope && scope.owner == object
  end

  def cache_key
    keys = [object.cache_key, 'v4']
    keys.push(scope.cache_key, scope.owner.cache_key) if scope
    keys
  end
end
