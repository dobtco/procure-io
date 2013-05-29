FactoryGirl.define do
  factory :organization do
    sequence(:name) { |i| "Oakland ##{i}" }
    sequence(:username) { |i| "oakland#{i}" }
    sequence(:email) { |i| "oakland#{i}@dobt.co" }
  end
end