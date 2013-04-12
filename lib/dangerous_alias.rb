module DangerousAlias
  extend ActiveSupport::Concern

  module ClassMethods
    def destructive_alias(method)
      class_eval """
        def #{method.to_s}!(*args)
          #{method.to_s}(*args)
          self.save
        end
      """
    end
  end
end

ActiveRecord::Base.send(:include, DangerousAlias)
