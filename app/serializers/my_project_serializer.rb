class MyProjectSerializer < ActiveModel::Serializer
  # cached true

  attributes :id,
             :slug,
             :title,
             :bids_due_at,
             :posted_at,
             :status_badge_class,
             :status_text,
             :total_submitted_bids,
             :user_is_collaborator

  # def cache_key
  #   [object.cache_key, 'v1']
  # end

  def user_is_collaborator
    Ability.new(scope).can? :collaborate_on, object
  end
end
