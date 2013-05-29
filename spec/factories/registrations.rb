# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration do
    name "MyString"
    organization_id 1
    registration_type 1
    form_options "MyText"
    vendor_can_update_status false
  end
end
