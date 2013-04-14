class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :body, :answer_body, :created_at_readable, :updated_at_readable

  def created_at_readable
    object.created_at.to_formatted_s(:readable) if object.created_at
  end

  def updated_at_readable
    object.updated_at.to_formatted_s(:readable) if object.updated_at
  end
end
