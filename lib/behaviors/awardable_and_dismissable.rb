module Behaviors
  module AwardableAndDismissable
    def self.included(base)
      base.belongs_to :dismisser, class_name: "User"
      base.belongs_to :awarder, class_name: "User"
      base.scope :dismissed, -> { base.where("dismissed_at IS NOT NULL") }
      base.scope :awarded, -> { base.where("awarded_at IS NOT NULL") }
      base.scope :where_open, -> { base.where("dismissed_at IS NULL AND awarded_at IS NULL") }
      base.question_alias :dismissed, :awarded
      base.dangerous_alias :unaward, :undismiss, :award, :dismiss
    end

    def dismiss(user, opts = {})
      return false if self.dismissed_at
      self.dismissed_at = Time.now
      self.dismisser_id = user.id
      self.dismissal_message = opts[:dismissal_message] if !opts[:dismissal_message].blank?
      self.show_dismissal_message_to_vendor = opts[:show_dismissal_message_to_vendor] if opts.has_key?(:show_dismissal_message_to_vendor)
      after_dismiss(user) if self.respond_to?(:after_dismiss, true)
    end

    def award(user, opts = {})
      return false if self.awarded_at
      self.awarded_at = Time.now
      self.awarder_id = user.id
      self.award_message = opts[:award_message] if !opts[:award_message].blank?
      after_award(user) if self.respond_to?(:after_award, true)
    end

    def undismiss(user)
      return false if !self.dismissed_at
      self.dismissed_at = nil
      self.dismisser_id = nil
      self.dismissal_message = nil
      self.show_dismissal_message_to_vendor = nil
      after_undismiss(user) if self.respond_to?(:after_undismiss, true)
    end

    def unaward(user)
      return false if !self.awarded_at
      self.awarded_at = nil
      self.awarder_id = nil
      self.award_message = nil
      after_unaward(user) if self.respond_to?(:after_unaward, true)
    end

    def dismissed
      dismissed_at ? true : false
    end

    def awarded
      awarded_at ? true : false
    end

    def awarded_dismissed_or_open_status
      if dismissed_at
        :dismissed
      elsif awarded_at
        :awarded
      else
        :open
      end
    end

    def awarded_dismissed_or_open_text_status
      I18n.t("g.#{awarded_dismissed_or_open_status}")
    end

  end
end
