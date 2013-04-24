module IsResponseFieldable
  def self.included(base)
    base.has_many :response_fields, as: :response_fieldable, dependent: :destroy
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
      response_fields << ResponseField.new(response_field)
    end

    update_attributes(form_options: form_template.form_options)
  end
end