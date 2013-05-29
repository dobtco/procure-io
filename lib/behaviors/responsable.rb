module Behaviors
  module Responsable
    def self.included(base)
      base.has_many :responses, as: :responsable, dependent: :destroy
    end

    def responsable_valid?
      responsable_errors.empty? ? true : false
    end

    def responsable_errors
      responsable_validator.errors
    end
  end
end
