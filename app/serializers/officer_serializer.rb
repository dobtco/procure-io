class OfficerSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :name, :display_name, :created_at, :title, :updated_at, :me?

  has_one :user

  def me?
    scope && scope.owner == object
  end

  def cache_key
    [object.cache_key, scope ? scope.cache_key : 'no-scope', 'v5']
  end
end
