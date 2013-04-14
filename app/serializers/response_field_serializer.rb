class ResponseFieldSerializer < ActiveModel::Serializer
  attributes :id, :label, :key_field, :field_type, :field_options, :sort_order
end