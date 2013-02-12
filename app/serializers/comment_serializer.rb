class CommentSerializer < ActiveModel::Serializer
  attributes :body, :comment_type, :commentable_id, :commentable_type, :data, :officer_id, :vendor_id, :created_at

  has_one :commentable
  has_one :officer
  has_one :vendor
end
