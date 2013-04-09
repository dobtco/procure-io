class ResponseSerializer < ActiveModel::Serializer
  attributes :id, :responsable_id, :responsable_type, :response_field_id, :value, :display_value

  has_one :response_field
end
