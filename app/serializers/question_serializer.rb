class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :body, :answer_body

  has_one :asker
  has_one :answerer

  def include_asker?
    @options[:include_asker]
  end

  def include_answerer?
    @options[:include_answerer]
  end
end
