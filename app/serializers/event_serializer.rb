class EventSerializer < ActiveModel::Serializer
  attributes :id, :read?, :path, :text
end
