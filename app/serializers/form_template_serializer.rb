class FormTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :urls

  def urls
    urls = {}

    urls[:edit] = edit_organization_form_template_path(object.organization, object)
    urls[:destroy] = organization_form_template_path(object.organization, object)

    urls
  end
end
