class VendorQuestionSerializer < QuestionSerializer
  attributes :officer_name

  def officer_name
    if object.officer
      object.officer.name
    end
  end
end
