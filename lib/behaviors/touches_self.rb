module Behaviors
  module TouchesSelf
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    def touch_self(*args)
      self.touch
    end
  end
end
