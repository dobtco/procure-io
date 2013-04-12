class OfficerSerializer < ActiveModel::Serializer
  attributes :id, :name, :display_name, :created_at, :title, :updated_at, :me?

  has_one :user

  def me?
    scope && scope == object
  end
end
