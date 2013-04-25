module Calculator
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def calculator(name, &block)
      define_method :"calculate_#{name}" do
        evaluated = instance_eval(&block)
        result = evaluated.respond_to?(:count) ? evaluated.count : evaluated
        self[name] = result
        result
      end

      dangerous_alias :"calculate_#{name}"
    end
  end
end