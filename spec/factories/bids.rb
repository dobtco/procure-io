FactoryGirl.define do
  factory :bid do
    vendor
    association :project, factory: :project_with_officers
    body Faker::Lorem.paragraphs(3).join("\n\n")
  end
end
