require 'spec_helper'

# @todo helper for refresh_page
describe "ResponseField" do

  subject { page }

  describe "logged in as officer" do
    before do
      sign_in(officers(:adam).user)
    end

    describe "index", js: true do
      before { visit response_fields_project_path(projects(:one)) }

      it "should render properly" do
        page.should have_selector(".response-field-wrapper:eq(1)", text: response_fields(:one).label)
        page.should have_selector(".response-field-wrapper:eq(1) input[type=text]")
        page.should have_selector(".response-field-wrapper:eq(2)", text: response_fields(:two).label)
        page.should have_selector(".response-field-wrapper:eq(2) textarea")
      end

      it "should be able to remove fields" do
        page.should have_selector("label", text: response_fields(:one).label)
        find(".response-field-wrapper:eq(1) .remove-field-button").click
        page.should_not have_selector("label", text: response_fields(:one).label)
        visit response_fields_project_path(projects(:one))
        page.should_not have_selector("label", text: response_fields(:one).label)
      end

      describe "adding fields" do
        it "should be able to add a text field" do
          page.should have_selector(".response-field-wrapper input[type=text]", count: 1)
          find("[data-backbone-add-field=text]").click
          page.should have_selector(".response-field-wrapper input[type=text]", count: 2)
          visit response_fields_project_path(projects(:one))
          page.should have_selector(".response-field-wrapper input[type=text]", count: 2)
        end

        it "should be able to add a paragraph field" do
          page.should have_selector(".response-field-wrapper textarea", count: 1)
          find("[data-backbone-add-field=paragraph]").click
          page.should have_selector(".response-field-wrapper textarea", count: 2)
          visit response_fields_project_path(projects(:one))
          page.should have_selector(".response-field-wrapper textarea", count: 2)
        end
      end

      describe "editing fields" do
        it "should show the correct edit panel when a field is clicked" do
          page.should_not have_selector("#edit-response-field-wrapper", visible: true)
          find(".response-field-wrapper:eq(1) .subtemplate-wrapper").click
          page.should have_selector("#edit-response-field-wrapper", visible: true)
          page.should have_text("Editing \"#{response_fields(:one).label}\"")
          find(".response-field-wrapper:eq(2) .subtemplate-wrapper").click
          page.should have_text("Editing \"#{response_fields(:two).label}\"")
        end

        describe "bindings" do
          before { find(".response-field-wrapper:eq(1) .subtemplate-wrapper").click }

          it "should bind the label field" do
            find("[data-rv-value=\"model.label\"]").set("NewLabel")
            page.should have_selector(".response-field-wrapper:eq(1)", text: "NewLabel")
          end

          it "should bind the description field" do
            find("[data-rv-value=\"model.field_options.description\"]").set("TheDescription")
            page.should have_selector(".response-field-wrapper:eq(1)", text: "TheDescription")
          end

          it "should bind the required field" do
            page.should have_selector(".response-field-wrapper:eq(1) .required-asterisk")
            find("[data-rv-checked=\"model.field_options.required\"]").set(false)
            page.should_not have_selector(".response-field-wrapper:eq(1) .required-asterisk")
          end

          it "should save properly" do
            find("[data-rv-value=\"model.label\"]").set("NewLabel2")
            find("[data-rv-value=\"model.field_options.description\"]").set("TheDescription")
            find("[data-rv-checked=\"model.field_options.required\"]").set(false)
            expect(page).to have_selector("[data-backbone-save-form]:not(.disabled)")
            click_button "Save Form"
            expect(page).to have_selector(".disabled[data-backbone-save-form]")
            visit response_fields_project_path(projects(:one))
            page.should have_selector(".response-field-wrapper:eq(1)", text: "NewLabel2")
            page.should have_selector(".response-field-wrapper:eq(1)", text: "TheDescription")
            page.should_not have_selector(".response-field-wrapper:eq(1) .required-asterisk")
          end
        end
      end
    end
  end
end