module Behaviors
  module Postable
    def self.included(base)
      base.belongs_to :poster, class_name: "User"
      base.scope :posted, -> { base.where("posted_at IS NOT NULL") }
      base.after_save :postable_after_save
      base.extend(ClassMethods)
      base.dangerous_alias :post, :unpost
      base.question_alias :posted
    end

    module ClassMethods
    end

    def posted=(x)
      if x == "1" || x == true
        self.post(self.current_user)
      else
        self.unpost(self.current_user)
      end
    end

    def posted
      self.posted_at ? true : false
    end

    def post(user)
      return false if self.posted
      self.posted_at = Time.now
      self.poster_id = user.id
    end

    def unpost(user)
      return false if !self.posted
      self.posted_at = nil
      self.poster_id = nil
    end

    def postable_after_save
      return unless posted_at_changed?

      if posted
        after_post(self.current_user) if self.respond_to?(:after_post, true)
      else
        after_unpost(self.current_user) if self.respond_to?(:after_unpost, true)
      end
    end
  end
end
