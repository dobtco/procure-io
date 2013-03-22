class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :body, :answer_body, :created_at_readable

  def created_at_readable
    object.created_at.to_formatted_s(:readable) if object.created_at
  end
end
