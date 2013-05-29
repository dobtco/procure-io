class EventSerializer < ActiveModel::Serializer
  attributes :id, :read?, :path, :text, :created_at
end
