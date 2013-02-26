class OfficerSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :display_name, :created_at, :title, :updated_at, :gravatar_url, :signed_up?, :me?

  def me?
    scope && scope == object
  end
end
