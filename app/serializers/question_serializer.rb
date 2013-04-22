class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :body, :answer_body
end
