class BidReviewSerializer < ActiveModel::Serializer
  attributes :id, :starred, :rating, :read

  has_one :officer

  def include_officer?
    @options[:include_officer]
  end
end
