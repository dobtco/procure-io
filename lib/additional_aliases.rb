module AdditionalAliases
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def dangerous_alias(*args)
      args.each do |method|
        class_eval """
          def #{method.to_s}!(*args)
            #{method.to_s}(*args)
            self.save
          end
        """
      end
    end

    def question_alias(*args)
      args.each do |method|
        class_eval """
          def #{method.to_s}?(*args)
            #{method.to_s}(*args)
          end
        """
      end
    end
  end
end
