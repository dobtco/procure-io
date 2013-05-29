class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_count, :urls

  def urls
    urls = {}

    urls[:edit] = edit_organization_team_path(object.organization.username, object)
    urls[:destroy] = organization_team_path(object.organization.username, object) unless object.is_owners

    urls
  end
end
