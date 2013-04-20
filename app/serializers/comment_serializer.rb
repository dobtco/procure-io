class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :comment_type, :commentable_id, :commentable_type, :data, :officer_id,
             :created_at, :created_at_readable

  has_one :officer
  has_one :commentable

  def include_commentable?
    @options[:include_commentable]
  end

  def created_at_readable
    object.created_at.to_formatted_s(:readable) if object.created_at
  end
end
