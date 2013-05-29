FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'
    completed_registration true
  end

  factory :user_with_organization, parent: :user do
    after(:create) do |u|
      organization = FactoryGirl.create(:organization)
      u.teams << organization.owners_team
    end
  end
end
