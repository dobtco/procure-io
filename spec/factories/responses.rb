FactoryGirl.define do
  factory :response do
    response_field { ResponseField.first || FactoryGirl.create(:response_field) }
    value { Faker::Lorem.word }
  end
end