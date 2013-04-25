module Behaviors
  module WatchableByUser
    def self.included(base)
      base.has_many :watches, as: :watchable, include: :user
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    def active_watchers(vendor_or_officer, opts = {})
      raise Exception unless vendor_or_officer.in? [:vendor, :officer]

      q = watches.not_disabled

      if vendor_or_officer == :vendor
        q = q.where_user_is_vendor
      else
        q = q.where_user_is_officer
      end

      not_users = Array(opts[:not_users]).reject{ |x| !x }
      if !not_users.empty?
        q = q.where("users.id NOT IN (?)", not_users.map(&:id))
      end

      q.map(&:user)
    end

    def watched_by?(user)
      watches.where(user_id: user.id, disabled: false).first ? true : false
    end

    def ever_watched_by?(user)
      watches.where(user_id: user.id).first ? true : false
    end
  end
end
