FactoryGirl.define do
  factory :officer do
    name Faker::Name.name
    title Faker::Company.position
    sequence(:email) { |n| "officer#{n}@example.gov" }
    password 'password'
  end
end
