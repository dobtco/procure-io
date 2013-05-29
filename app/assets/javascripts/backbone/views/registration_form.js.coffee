ProcureIo.Backbone.RegistrationFormAddFieldView = Backbone.View.extend
  el: "#addField"

  initialize: ->
    @parentView = @options.parentView

  render: ->
    @$el.html JST['registration_form/add_field']()

  addExistingField: (e, $el, field_type) ->
    attrs =
      key: field_type
      sort_order: @parentView.collection.nextSortOrder()
      field_options:
        required: true
        vendor_profile: true

    switch field_type
      when "address_line_1"
        attrs.label = "Address line 1"
        attrs.field_type = 'text'
      when "address_line_2"
        attrs.label = "Address line 2"
        attrs.field_type = 'text'
      when "city"
        attrs.label = "City"
        attrs.field_type = 'text'
      when "state"
        attrs.label = "State"
        attrs.field_type = 'text'
      when "zip"
        attrs.label = "Zip"
        attrs.field_type = 'text'

    $(".bid-form-span").addClass 'loading'

    @parentView.collection.create attrs,
      wait: true
      success: (rf) =>
        @parentView.createAndShowEditView(rf)
