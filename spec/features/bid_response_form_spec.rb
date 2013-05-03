require 'spec_helper'

include BidResponseFormSpecHelper

describe "Bid Response Form" do

  before do
    sign_in(officers(:adam).user)
  end

  describe "project#response_fields", js: true do
    before { visit response_fields_project_path(projects(:one)) }

    it "should render properly" do
      # Text field
      ensure_repsonse_field_shown(response_fields(:one), 1)
      response_field(1).should have_selector("input[type=text]")

      # Paragraph field
      ensure_repsonse_field_shown(response_fields(:two), 2)
      response_field(2).should have_selector("textarea")

      # @todo more
    end

    it "should be able to remove fields" do
      ensure_repsonse_field_shown(response_fields(:one))
      response_field(1).find(".remove-field-button").click
      before_and_after_refresh do
        ensure_repsonse_field_not_shown(response_fields(:one))
      end
    end

    it "should be able to add fields" do
      # Text field
      count = all(".response-field-wrapper input[type=text]").length
      add_response_field('text')
      before_and_after_refresh do
        page.should have_selector(".response-field-wrapper input[type=text]", count: count + 1)
      end

      # Paragraph field
      count = all(".response-field-wrapper textarea").length
      add_response_field('paragraph')
      before_and_after_refresh do
        page.should have_selector(".response-field-wrapper textarea", count: count + 1)
      end
    end

    it "it should show the correct edit panel when a field is clicked" do
      page.should_not be_showing_edit_panel
      edit_response_field(1)
      page.should be_showing_edit_panel
      ensure_editing_response_field(response_fields(:one))
      edit_response_field(2)
      ensure_editing_response_field(response_fields(:two))
    end

    it 'should bind the appropriate attributes' do
      # Bind label field
      edit_response_field(1)
      set_response_field_value('label', 'NewLabel')
      before_and_after_save { response_field(1).should have_text('NewLabel') }

      # Bind the description field
      edit_response_field(1)
      set_response_field_value('description', 'TheDescription')
      before_and_after_save { page.should have_selector(".response-field-wrapper:eq(1)", text: "TheDescription") }

      # Bind the required field
      edit_response_field(1)
      response_field(1).should_not be_optional
      set_response_field_value('required', false)
      before_and_after_save { response_field(1).should be_optional }
    end
  end
end