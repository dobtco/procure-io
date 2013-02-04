FactoryGirl.define do
  factory :project do |project|
    title Faker::Lorem.words(3).join(" ")
    body Faker::Lorem.paragraphs(3).join("\n\n")

    factory :project_with_officers do
      after(:create) do |p|
        p.officers << Officer.all
        p.collaborators.first.update_attributes owner: true
      end
    end
  end
end
