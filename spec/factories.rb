FactoryGirl.define do
  factory :bid do
    vendor { (Vendor.all.count > 0 ? Vendor.all(order: "RANDOM()").first : FactoryGirl.create(:vendor)) }
    project { (Project.all.count > 0 ? Project.first : FactoryGirl.create(:project)) }
    body { Faker::Lorem.paragraphs(3).join("\n\n") }
    submitted_at { rand(1..8) == 1 ? nil : Time.now }

    after(:create) do |b|
      # make sure the first project is posted, since we're giving it lots of bids
      if Project.first then Project.first.update_attributes(posted: true) end

      b.project.response_fields.each do |response_field|
        b.bid_responses.create(response_field_id: response_field.id, value: Faker::Lorem.word)
      end
    end
  end

  factory :comment do
    commentable { (Bid.all.count > 0 ? Bid.first : FactoryGirl.create(:bid)) }
    officer { (Officer.all.count > 0 ? Officer.first : FactoryGirl.create(:officer)) }
    body { Faker::Lorem.paragraph }
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

    after(:create) do |p|
      p.officers << Officer.all
      p.collaborators.first.update_attributes owner: true
      p.response_fields.create(label: "Name", field_type: "text", sort_order: 0)
      p.response_fields.create(label: "# of cats", field_type: "text", sort_order: 1)
      p.tags << Tag.all(order: "RANDOM()").first
      p.tags << Tag.all(order: "RANDOM()").first if rand(1..5) == 5
    end
  end

  factory :vendor do
    name { Faker::Name.name }
    sequence(:email) { |n| "vendor#{n}@example.com" }
    password 'password'
  end

  factory :question do
    vendor { (Vendor.all.count > 0 ? Vendor.all(order: "RANDOM()").first : FactoryGirl.create(:vendor)) }
    project { (Project.all.count > 0 ? Project.all(order: "RANDOM()").first : FactoryGirl.create(:project)) }
    body { Faker::Lorem.paragraph }

    after(:build) do |q|
      if rand(1..2) == 2 && q.project.posted
        q.answer_body = Faker::Lorem.paragraph
        q.officer = (Officer.all.count > 0 ? Officer.all(order: "RANDOM()").first : FactoryGirl.create(:officer))
      end
    end
  end

  factory :tag do
    name { Faker::Product::NOUN.rand }
  end
end
