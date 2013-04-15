class ActionView::Helpers::FormBuilder
  include ActionView::Helpers::FormTagHelper

  def required_label(method, options = {})
    return label_tag(method, nil, class: 'label-required')
  end

  def optional_label(method, options = {})
    return label_tag(method, "#{@object.class.human_attribute_name(method)} (optional)", class: 'label-optional')
  end
end
