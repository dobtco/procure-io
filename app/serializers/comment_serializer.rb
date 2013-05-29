class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :commentable_id, :commentable_type, :data, :created_at

  has_one :user
  has_one :commentable

  def include_commentable?
    @options[:include_commentable]
  end
end
