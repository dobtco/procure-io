class BidSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :created_at, :updated_at, :submitted_at, :dismissed_at, :dismissed_by_officer_id,
             :project_id, :total_comments, :total_stars, :awarded_at, :awarded_by_officer_id,
             :average_rating, :total_ratings, :watching?, :labels, :bidder_name, :dismissal_message,
             :show_dismissal_message_to_vendor, :award_message

  has_one :vendor

  has_many :responses

  def labels
    if object.labels.loaded?
      object.labels.map(&:id)
    else
      object.labels.pluck(:id)
    end
  end

  def responses
    q = object.responses

    if !scope || !Ability.new(scope).can?(:view_only_visible_to_admin_fields, ResponseField)
      q = q.without_only_visible_to_admin_fields
    end

    q
  end

  def average_rating
    # round to 2 decimal places
    sprintf('%.2f', object.average_rating) if object.average_rating
  end

  def cache_key
    [object.cache_key, object.project.cache_key, scope ? scope.cache_key : 'no-scope', 'v12']
  end

  def watching?
    if defined?(object.i_am_watching)
      object.i_am_watching?
    else
      scope && scope.watches?(object)
    end
  end
end
