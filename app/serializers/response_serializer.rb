class ResponseSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :response_field_id, :display_value

  def cache_key
    [object.cache_key, 'v1']
  end
end
