FactoryGirl.define do
  factory :vendor do
    sequence(:name) { |n| ProcureFaker::Vendor.name(n) }
    sequence(:email) { |n| "vendor#{n}@example.com" }
    contact_name "Adam Becker"
    phone_number "877-294-DOBT"
    address_line_1 "123 Main St."
    address_line_2 "#45"
    city "Oakland"
    state "CA"
    zip "94609"
  end
end