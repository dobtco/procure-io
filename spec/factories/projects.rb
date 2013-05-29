FactoryGirl.define do
  factory :project do
    sequence(:title) { |n| ProcureFaker::Project.title(n) }
    body { ProcureFaker::Project.body }
    bids_due_at { Time.now + rand(1..8).weeks }
    organization { Organization.first || FactoryGirl.build(:organization) }
  end

  factory :project_with_response_fields, parent: :project do
    after(:create) do |p|
      p.response_fields.create(label: "Completion Time", field_type: "text", sort_order: 0)
      p.response_fields.create(label: "Total Cost", field_type: "price", sort_order: 1, field_options: {"required" => true})
      p.response_fields.create(label: "Your Approach", field_type: "paragraph", sort_order: 2, field_options: {"size" => 'large', "required" => true, "description" => "How would you complete this project?"})
    end
  end
end
