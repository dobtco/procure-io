 module Behaviors
  module Watchable
    def self.included(base)
      base.has_many :watches, -> { includes(:user) }, as: :watchable
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    def active_watchers(opts = {})
      q = watches.not_disabled

      not_users = Array(opts[:not_users]).reject{ |x| !x }
      if !not_users.empty?
        q = q.where("users.id NOT IN (?)", not_users.map(&:id)).references(:users)
      end

      users = q.map(&:user)

      if opts[:user_can]
        users.select do |user|
          Ability.new(user).can? opts[:user_can], self
        end
      end

      users
    end

    def watched_by?(user)
      watches.where(user_id: user.id, disabled: false).first ? true : false
    end

    def ever_watched_by?(user)
      watches.where(user_id: user.id).first ? true : false
    end
  end
end
