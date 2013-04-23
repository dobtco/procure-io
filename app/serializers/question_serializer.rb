class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :body, :answer_body

  has_one :vendor

  def include_vendor?
    @options[:include_vendor]
  end
end
