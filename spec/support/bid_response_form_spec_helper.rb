module BidResponseFormSpecHelper
  def ensure_repsonse_field_shown(response_field, pos = nil, should_not = false)
    page.send(should_not ? :should_not : :should)
      have_selector(".response-field-wrapper#{if pos then ':eq('+pos.to_s+')' end}", text: response_field.label)
  end

  def ensure_repsonse_field_not_shown(response_field, pos = nil)
    ensure_repsonse_field_shown(response_field, pos, true)
  end

  def response_field(pos)
    find(".response-field-wrapper:eq(#{pos})")
  end

  def add_response_field(response_field_type)
    find("[data-backbone-add-field=#{response_field_type}]").click
  end

  def be_showing_edit_panel
    have_selector("#edit-response-field-wrapper", visible: true)
  end

  def ensure_editing_response_field(response_field)
    page.should have_text("Editing \"#{response_field.label}\"")
  end

  def set_response_field_value(response_field_type, value)
    field = case response_field_type
    when 'label'
      find("[data-rv-value=\"model.label\"]")
    when 'description'
      find("[data-rv-value=\"model.field_options.description\"]")
    when 'required'
      find("[data-rv-checked=\"model.field_options.required\"]")
    end

    field.set(value)
    field.trigger('change')
  end

  def be_optional
    have_selector(".is-optional")
  end

  def edit_response_field(num)
    find(".response-field-wrapper:eq(#{num}) .subtemplate-wrapper").click
  end

  def be_saved
    have_selector("[data-backbone-save-form].disabled")
  end

  def before_and_after_save(&block)
    instance_eval(&block)
    page.should_not be_saved
    click_button "Save Form"
    page.should be_saved
    refresh
    instance_eval(&block)
  end
end
