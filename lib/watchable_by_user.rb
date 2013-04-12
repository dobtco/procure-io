module WatchableByUser
  def self.included(base)
    base.has_many :watches, as: :watchable
    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def watched_by?(user)
    watches.where(user_id: user.id, disabled: false).first ? true : false
  end

  def ever_watched_by?(user)
    watches.where(user_id: user.id).first ? true : false
  end
end