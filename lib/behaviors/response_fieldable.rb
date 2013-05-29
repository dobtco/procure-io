module Behaviors
  module ResponseFieldable
    def self.included(base)
      base.has_many :response_fields, as: :response_fieldable, dependent: :destroy
      base.serialize :form_options, Hash
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    def key_fields
      response_fields.where(key_field: true)
    end

    def use_form_template!(form_template)
      response_fields.destroy_all

      form_template.response_fields.each do |response_field|
        response_fields << ResponseField.new(pick(response_field, *ResponseField::ALLOWED_PARAMS))
      end

      update_attributes(form_options: form_template.form_options)
    end

    def form_confirmation_message
      if !form_options["form_confirmation_message"].blank?
        form_options["form_confirmation_message"]
      else
        I18n.t("g.#{self.class.name.downcase}_form_confirmation_message")
      end
    end
  end
end
