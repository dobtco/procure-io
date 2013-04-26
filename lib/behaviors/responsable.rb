module Behaviors
  module Responsable
    def self.included(base)
      base.has_many :responses, as: :responsable, dependent: :destroy
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    def responsable_valid?
      responsable_errors.empty? ? true : false
    end

    def responsable_errors
      responsable_validator.errors
    end

    def key_field_responses
      responses.where("response_field_id IN (?)", project.key_fields.map(&:id))
    end
  end
end
