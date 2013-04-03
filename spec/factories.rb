FactoryGirl.define do
  factory :bid do
    vendor { (Vendor.all.count > 0 ? Vendor.all(order: "RANDOM()").first : FactoryGirl.create(:vendor)) }
    project { (Project.all.count > 0 ? Project.all(order: "RANDOM()").first : FactoryGirl.create(:project)) }
    submitted_at { rand(1..8) == 1 ? nil : (Time.now - rand(0..5).days) }

    factory :bid_with_reviews do
      after(:create) do |b|
        rand(0..2).times do
          review = b.bid_review_for_officer(Officer.all(order: "RANDOM()").first)
          review.read = rand(0..1) == 1
          review.starred = rand(0..1) == 1
          review.save
        end
      end
    end

    after(:create) do |b|
      # make sure the first project is posted, since we're giving it lots of bids
      if Project.first then Project.first.update_attributes(posted_at: Time.now - 7.days, posted_by_officer_id: Officer.first.id) end

      b.project.response_fields.each do |response_field|
        if response_field.label == "Completion Time"
          b.bid_responses.create(response_field_id: response_field.id, value: "#{rand(1..8)} weeks")
        elsif response_field.label == "Total Cost"
          b.bid_responses.create(response_field_id: response_field.id, value: "#{rand(1000..5000)}")
        elsif response_field.label == "Your Approach"
          b.bid_responses.create(response_field_id: response_field.id, value: Faker::Lorem.paragraphs.join("\n\n"))
        elsif response_field.label == "Security"
          b.bid_responses.create(response_field_id: response_field.id, value: {"I understand all of the necessary security procedures." => true})
        else
          b.bid_responses.create(response_field_id: response_field.id, value: Faker::Lorem.word)
        end
      end

      rand(0..2).times do
        label = b.project.labels(order: "RANDOM()").first
        b.labels << label if label and !b.labels.exists?(label)
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
    role { Officer.roles[:god] }
  end

  factory :project do |project|
    sequence(:title) { |n| ProcureFaker::Project.title(n) }
    body { ProcureFaker::Project.body }
    bids_due_at { Time.now + rand(1..8).weeks }

    factory :project_with_bids do
      after(:create) do |p|
        Vendor.all.each do |v|
          FactoryGirl.create(:bid_with_reviews, vendor: v, project: p) unless rand(1..8) == 1
        end
      end
    end

    after(:create) do |p|
      if rand(1..2) == 1
        p.posted_by_officer_id = Officer.all(order: "RANDOM()").first.id
        p.posted_at = (Time.now - rand(7..14).days)
        p.save
      end

      p.officers << Officer.all
      p.collaborators.first.update_attributes owner: true
      p.response_fields.create(label: "Completion Time", field_type: "text", sort_order: 0)
      p.response_fields.create(label: "Total Cost", field_type: "price", sort_order: 1, field_options: {"required" => true})
      p.response_fields.create(label: "Your Approach", field_type: "paragraph", sort_order: 2, field_options: {"size" => 'large', "required" => true, "description" => "How would you complete this project?"})
      p.response_fields.create(label: "Security", field_type: "checkboxes", sort_order: 3,
                               field_options: {"required" => true, "options" => [{"label" => "I understand all of the necessary security procedures.", "checked" => false}]})
      p.tags << Tag.all(order: "RANDOM()").first

      Officer.all.each do |officer|
        officer.watch!("Project", p.id)
      end

      Vendor.all.each do |vendor|
        vendor.watch!("Project", p.id) if rand(1..2) == 2
      end

      FactoryGirl.create(:comment, commentable: p)
      rand(0..5).times do |i|
        FactoryGirl.create(:label, project: p, name: ProcureFaker::Label.name(i))
      end
    end
  end

  factory :vendor do
    sequence(:name) { |n| ProcureFaker::Vendor.name(n) }
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
    sequence(:name) { |n| ProcureFaker::Tag.name(n) }
  end

  factory :amendment do
    project { (Project.all.count > 0 ? Project.first : FactoryGirl.create(:project)) }
    title "Amendment to the statement of work"
    body "The due date for new proposals is now extended by two weeks."

    after(:create) do |a|
      a.post_by_officer!(Officer.all(order: "RANDOM()").first)
    end
  end

  factory :label do
    project { (Project.all.count > 0 ? Project.first : FactoryGirl.create(:project)) }
    name { ProcureFaker::Label.name }
    color { ProcureFaker::Label.color }
  end
end
