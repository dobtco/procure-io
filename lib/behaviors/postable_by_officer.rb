module Behaviors
  module PostableByOfficer
    def self.included(base)
      base.belongs_to :posted_by_officer, foreign_key: "posted_by_officer_id", class_name: "Officer"
      base.scope :posted, base.where("posted_at IS NOT NULL")
      base.extend(ClassMethods)
      base.dangerous_alias :post_by_officer, :unpost_by_officer
      base.question_alias :posted
    end

    module ClassMethods
    end

    def posted
      self.posted_at ? true : false
    end

    def post_by_officer(officer)
      return false if self.posted_at
      self.posted_at = Time.now
      self.posted_by_officer_id = officer.id
      after_post_by_officer(officer) if self.respond_to?(:after_post_by_officer, true)
    end

    def unpost_by_officer(officer)
      self.posted_at = nil
      self.posted_by_officer_id = nil
      after_unpost_by_officer(officer) if self.respond_to?(:after_unpost_by_officer, true)
    end
  end
end
