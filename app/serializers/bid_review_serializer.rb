class BidReviewSerializer < ActiveModel::Serializer
  attributes :id, :starred, :rating, :read

  has_one :user

  def include_user?
    @options[:include_user]
  end
end
