class VendorBidSerializer < ActiveModel::Serializer
  # cached true

  attributes :id,
             :created_at,
             :updated_at,
             :submitted_at,
             :dismissed_at,
             :vendor_dismissal_message,
             :award_message,
             :text_status,
             :badge_class,
             :updated_by_vendor_at,
             :url

  has_one :project, serializer: VendorProjectSerializer

  def url
    vendor_bid_path(object.vendor, object)
  end

  # def cache_key
  #   [object.cache_key, object.project.cache_key, scope ? scope.cache_key : 'no-scope', 'v12']
  # end
end
