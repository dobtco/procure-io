module Behaviors
  module Submittable
    def self.included(base)
      base.scope :submitted, -> { base.where("submitted_at IS NOT NULL") }
      base.question_alias :submitted
      base.dangerous_alias :submit
    end

    def submit
      return if self.submitted_at
      self.submitted_at = Time.now
      after_submit if self.respond_to?(:after_submit, true)
    end

    def submitted
      self.submitted_at ? true : false
    end
  end
end
