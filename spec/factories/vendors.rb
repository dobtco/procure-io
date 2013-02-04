FactoryGirl.define do
  factory :vendor do
    sequence(:email) { |n| "vendor#{n}@example.com" }
    password 'password'
  end
end
