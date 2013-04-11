module SharedUserMethods
  def self.included(base)
    base.has_one :user, as: :owner
  end
end