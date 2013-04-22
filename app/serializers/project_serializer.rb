class ProjectSerializer < ActiveModel::Serializer
  cached true

  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at, :form_options, :review_mode

  has_many :tags
  has_many :labels

  has_many :response_fields
  has_many :key_fields

  def response_fields
    if scope && Ability.new(scope).can?(:view_only_visible_to_admin_fields, ResponseField)
      object.response_fields
    else
      object.response_fields.without_only_visible_to_admin_fields
    end
  end

  def abstract
    object.abstract_or_truncated_body
  end

  def review_mode
    Project.review_modes[object.review_mode]
  end

  def cache_key
    [object.cache_key, scope ? scope.cache_key : 'no-scope', 'v3']
  end
end
