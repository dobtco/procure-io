class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :comment_type, :commentable_id, :commentable_type, :data, :officer_id,
             :created_at

  has_one :officer
  has_one :commentable

  def include_commentable?
    @options[:include_commentable]
  end
end
