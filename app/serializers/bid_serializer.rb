class BidSerializer < ActiveModel::Serializer
  # cached true

  attributes :id, :created_at, :updated_at, :submitted_at, :dismissed_at, :dismissed_by_officer_id,
             :project_id, :total_comments, :total_stars, :awarded_at, :awarded_by_officer_id,
             :submitted_at_readable, :average_rating, :total_ratings, :watching?, :labels

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

  def submitted_at_readable
    object.submitted_at.to_formatted_s(:readable) if object.submitted_at
  end

  def average_rating
    # round to 2 decimal places
    sprintf('%.2f', object.average_rating) if object.average_rating
  end

  # def cache_key
  #   keys = [object.cache_key, 'v3']
  #   keys.push(scope.cache_key, scope.owner.cache_key) if scope
  #   keys
  # end

  def watching?
    if object.i_am_watching != nil
      object.i_am_watching?
    else
      scope && scope.watches?("Bid", object.id)
    end
  end
end
