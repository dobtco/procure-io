class FormTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :urls

  def urls
    urls = {}

    urls[:edit] = edit_form_template_path(object)
    urls[:destroy] = form_template_path(object)

    urls
  end
end
