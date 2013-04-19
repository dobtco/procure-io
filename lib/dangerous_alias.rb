module DangerousAlias
  def self.included(base)
    base.belongs_to :posted_by_officer, foreign_key: "posted_by_officer_id", class_name: "Officer"
    base.extend(ClassMethods)
  end

  module ClassMethods
    def dangerous_alias(method)
      class_eval """
        def #{method.to_s}!(*args)
          #{method.to_s}(*args)
          self.save
        end
      """
    end
  end
end
