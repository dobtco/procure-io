FactoryGirl.define do
  factory :bid do
    vendor { (Vendor.all.count > 0 ? Vendor.all(order: "RANDOM()").first : FactoryGirl.create(:vendor)) }
    project { (Project.all.count > 0 ? Project.first : FactoryGirl.create(:project)) }
    submitted_at { rand(1..8) == 1 ? nil : Time.now }

    after(:create) do |b|
      # make sure the first project is posted, since we're giving it lots of bids
      if Project.first then Project.first.update_attributes(posted_at: Time.now, posted_by_officer_id: Officer.first.id) end

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
    title { ProcureFaker::Project.title }
    body { ProcureFaker::Project.body }
    bids_due_at { Time.now + rand(1..8).weeks }

    after(:create) do |p|
      if rand(1..2) == 1
        p.post_by_officer!(Officer.all(order: "RANDOM()").first)
      end

      p.officers << Officer.all
      p.collaborators.first.update_attributes owner: true
      p.response_fields.create(label: "Name", field_type: "text", sort_order: 0)
      p.response_fields.create(label: "# of cats", field_type: "text", sort_order: 1)
      p.tags << Tag.all(order: "RANDOM()").first
      p.tags << Tag.all(order: "RANDOM()").first if rand(1..5) == 5

      Officer.all.each do |officer|
        officer.watch!("Project", p.id)
      end

      Vendor.all.each do |vendor|
        vendor.watch!("Project", p.id) if rand(1..2) == 2
      end

      FactoryGirl.create(:comment, commentable: p)
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
    body { ProcureFaker::Question.body }

    after(:build) do |q|
      if rand(1..2) == 2 && q.project.posted_at
        q.answer_body = Faker::Lorem.paragraph
        q.officer = (Officer.all.count > 0 ? Officer.all(order: "RANDOM()").first : FactoryGirl.create(:officer))
        q.save
      end
    end
  end

  factory :tag do
    name { Faker::Product::NOUN.rand }
  end

  factory :amendment do
    project { (Project.all.count > 0 ? Project.first : FactoryGirl.create(:project)) }
    title "Amendment to the statement of work"
    body "The due date for new proposals is now extended by two weeks."

    after(:create) do |a|
      a.post_by_officer!(Officer.all(order: "RANDOM()").first)
    end
  end
end
