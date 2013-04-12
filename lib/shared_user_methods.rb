module SharedUserMethods
  def self.included(base)
    base.has_one :user, as: :owner
    base.accepts_nested_attributes_for :user
  end
end