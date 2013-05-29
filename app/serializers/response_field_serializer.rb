class ResponseFieldSerializer < ActiveModel::Serializer
  attributes :id, :label, :field_type, :field_options, :sort_order, :only_visible_to_admin
end