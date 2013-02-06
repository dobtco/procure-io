FactoryGirl.define do
  factory :bid do
    vendor { (Vendor.all.count > 0 ? Vendor.all(order: "RANDOM()").first : Factory.create(:vendor)) }
    project { (Project.all.count > 0 ? Project.all(order: "RANDOM()").first : Factory.create(:project)) }
    body { Faker::Lorem.paragraphs(3).join("\n\n") }
  end

  factory :officer do
    name { Faker::Name.name }
    title { Faker::Company.position }
    sequence(:email) { |n| "officer#{n}@example.gov" }
    password 'password'
  end

  factory :project do |project|
    title { Faker::Lorem.words(3).join(" ") }
    body { Faker::Lorem.paragraphs(3).join("\n\n") }
    bids_due_at { Time.now + rand(1..8).weeks }
    posted { rand(1..2) == 1 }

    factory :project_with_officers do
      after(:create) do |p|
        p.officers << Officer.all
        p.collaborators.first.update_attributes owner: true
      end
    end
  end

  factory :vendor do
    name { Faker::Name.name }
    sequence(:email) { |n| "vendor#{n}@example.com" }
    password 'password'
  end

  factory :question do
    vendor { (Vendor.all.count > 0 ? Vendor.all(order: "RANDOM()").first : Factory.create(:vendor)) }
    project { (Project.all.count > 0 ? Project.all(order: "RANDOM()").first : Factory.create(:project)) }
    body { Faker::Lorem.paragraph }

    after(:build) do |q|
      if rand(1..2) == 2
        q.answer_body = Faker::Lorem.paragraph
        q.officer = (Officer.all.count > 0 ? Officer.all(order: "RANDOM()").first : Factory.create(:officer))
      end
    end
  end
end
