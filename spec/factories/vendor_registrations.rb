# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vendor_registration do
    registration_id 1
    vendor_id 1
    status 1
    notes "MyText"
  end
end
