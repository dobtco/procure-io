FactoryGirl.define do
  factory :bid do
  end

  factory :bid_for_project, parent: :bid do
    after(:create) do |b|
      b.submit!
      b.project.response_fields.each do |response_field|
        case response_field.label
        when "Completion Time"
          b.responses.create(response_field_id: response_field.id, value: "#{response_field.id} #{rand(1..8)} weeks")
        when "Total Cost"
          b.responses.create(response_field_id: response_field.id, value: "#{rand(1000..100000)}")
        when "Your Approach"
          b.responses.create(response_field_id: response_field.id, value: Faker::Lorem.paragraphs.join("\n\n") + response_field.id.to_s)
        else
          b.responses.create(response_field_id: response_field.id, value: Faker::Lorem.word + response_field.id.to_s)
        end
      end
    end
  end
end